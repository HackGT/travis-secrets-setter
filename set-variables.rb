require 'travis'

Travis.access_token = ENV['TRAVIS_TOKEN']

repos = Travis::Repository
	.find_all(owner_name: 'HackGT')
	.reject{|repo| repo.slug == 'HackGT/travis-secrets-setter'}
	.select{|repo| Travis.user.admin_access.include?(repo)}

keys = [
	'DOCKER_PASSWORD',
	'TRAVIS_TOKEN',
    'GH_TOKEN',
    'CLOUDFLARE_ZONE',
    'CLOUDFLARE_EMAIL',
    'CLOUDFLARE_AUTH',
]


puts %x(
	set -euox
	mkdir -p biodomes/dev
	cd biodomes
	git init
	git config user.name "Michael Eden"
	git config user.email "themichaeleden@gmail.com"

	git remote add upstream "https://#{ENV['GH_TOKEN']}@github.com/HackGT/biodomes.git"
	git fetch upstream
	git reset --hard upstream/master
)

raise 'Could not set up git repo!' if $?.exitstatus != 0

repos.each do |repo|
	# Set all the secrets
	keys.each do |key|
		puts "Setting env var '#{key}' on project '#{repo.slug}'"
		repo.env_vars.upsert(key, "'#{ENV[key]}'", public: false)
	end

	puts "Enabling project #{repo.slug}."
	repo.enable

	biodome_path = "biodomes/dev/#{File.basename repo.slug.downcase}.yaml"
	unless File.exist? biodome_path
		puts 'Creating default config in biodomes.'
		File.open biodome_path, 'w' do |file|
			file.write("git: https://github.com/#{repo.slug}.git")
		end
	end
end

puts %x(
	set -euox
	cd biodomes
	touch .
	if [ -n "$(git status -s)" ]; then
		git add -A .
		git commit -m 'Automated Commit: add new repos.'
		git push -q upstream HEAD:master
	fi
)

raise 'Could not push to git!' if $?.exitstatus != 0
