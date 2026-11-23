#!/bin/bash
set -euo pipefail

query="$(cat)"
field() {
  local rest="${query#*\"${1}\":\"}"
  if [[ "$rest" == "$query" ]]; then
    echo "query has no ${1}" >&2
    exit 1
  fi
  printf '%s' "${rest%%\"*}"
}
host="$(field host)"
username="$(field username)"
create_user="$(field create_user)"

token="$(ssh -o IdentitiesOnly=yes -o BatchMode=yes -o ConnectTimeout=20 -i "${HOME}/.ssh/id_ed25519" "ubuntu@${host}" sudo bash -s -- "$username" "$create_user" <<'EOS'
set -euo pipefail
username="$1"
create_user="$2"
if [[ -s /srv/gitlab/terraform-pat ]]; then
  existing="$(tr -d "\n" < /srv/gitlab/terraform-pat)"
else
  existing=""
fi
raw="$(printf '%s\n%s\n%s' "$username" "$create_user" "$existing" | docker exec -i gitlab gitlab-rails runner '
username, create_user, existing = STDIN.read.split("\n", 3)
existing = existing.to_s.strip
user = User.find_by_username(username)
unless user
  raise "GitLab user #{username} does not exist" unless create_user == "true"
  password = SecureRandom.hex(24)
  created = Users::CreateService.new(User.find_by_username!("root"), {
    username: username,
    name: username,
    email: "#{username}@stand.invalid",
    password: password,
    password_confirmation: password,
    admin: true,
    skip_confirmation: true,
    organization_id: Organizations::Organization.default_organization.id
  }).execute
  user = created.respond_to?(:persisted?) ? created : created.payload[:user]
  raise user.errors.full_messages.join(", ") unless user.persisted?
end
current = existing.empty? ? nil : PersonalAccessToken.find_by_token(existing)
if current&.user_id == user.id && current.active?
  puts "TF_PAT:#{existing}"
else
  user.personal_access_tokens.where(name: "terraform").find_each { |pat| pat.revoke! unless pat.revoked? }
  created_token = user.personal_access_tokens.create!(name: "terraform", scopes: ["api"], expires_at: 365.days.from_now)
  User.find_by_username("root").personal_access_tokens.where(name: "terraform").find_each { |pat| pat.revoke! unless pat.revoked? }
  puts "TF_PAT:#{created_token.token}"
end
' | sed -n "s/^TF_PAT://p")"
if [[ -z "$raw" ]]; then
  echo "token was not issued" >&2
  exit 1
fi
umask 077
printf "%s" "$raw" > /srv/gitlab/terraform-pat
chmod 600 /srv/gitlab/terraform-pat
printf "%s" "$raw"
EOS
)"

printf '{"token":"%s"}\n' "$token"
