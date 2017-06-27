require 'travis'

Travis.access_token = ENV['TRAVIS_TOKEN']

repos = Travis::Repository
	.find_all(owner_name: 'HackGT')
	.reject{|repo| repo.slug == 'HackGT/travis-secrets-setter'}
	.select{|repo| Travis.user.admin_access.include?(repo)}

keys = [
	'DOCKER_PASSWORD',
]

repos.each do |repo|
	keys.each do |key|
		puts "Setting env var '#{key}' on project '#{repo.slug}'"
		repo.env_vars.upsert(key, "'#{ENV[key]}'", public: false)
	end
end
