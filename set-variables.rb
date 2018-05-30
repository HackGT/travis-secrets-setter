require 'travis'

Travis::Pro.access_token = ENV["ACCESS_TOKEN"]

user = Travis::Pro::User.current
repos = user.repositories.sort_by(&:slug).select do |repo|
  next false unless repo.owner_name == "HackGT"
  true
end

keys = %w(
  DOCKER_PASSWORD
  GH_TOKEN
  CLOUDFLARE_ZONE
  CLOUDFLARE_EMAIL
  CLOUDFLARE_AUTH
  TRAVIS_TOKEN
)

puts `
  set -euox
  mkdir -p biodomes/dev
  cd biodomes
  git init
  git config user.name "Michael Eden"
  git config user.email "themichaeleden@gmail.com"

  git remote add upstream \
    "https://#{ENV['GH_TOKEN']}@github.com/HackGT/biodomes.git"
  git fetch upstream
  git reset --hard upstream/master
`

raise 'Could not set up git repo!' if $?.exitstatus != 0

repos.each do |repo|
  puts "Enabling project #{repo.slug}. #{repo.active}"
  repo.enable

  # Set all the secrets
  keys.each do |key|
    puts "Setting env var '#{key}' on project '#{repo.slug}'"
    repo.env_vars.upsert(key, "'#{ENV[key]}'", public: false)
  end
end

puts `
  set -euox
  cd biodomes
  touch .
  if [ -n "$(git status -s)" ]; then
    git add -A .
    git commit -m 'Automated Commit: add new repos.'
    git push -q upstream HEAD:master
  fi
`

raise 'Could not push to git!' if $?.exitstatus != 0
