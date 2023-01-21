# frozen_string_literal: true

LONG_DESCRIPTION = 'A plugin-based tool to fetch stats, with a GitHub stat fetcher included by default'

Gem::Specification.new do |spec|
  spec.name                               = 'repofetch'
  spec.version                            = '0.5.0'
  spec.authors                            = ['Spenser Black']

  spec.summary                            = 'A plugin-based stat fetcher'
  spec.description                        = LONG_DESCRIPTION

  spec.homepage                           = 'https://github.com/spenserblack/repofetch'
  spec.license                            = 'MIT'

  spec.required_ruby_version              = Gem::Requirement.new('>= 2.7.0')

  spec.files                              = Dir['lib/**/*'] + Dir['exe/*'] + Dir['[A-Z]*']

  spec.bindir                             = 'exe'
  spec.executables                        = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths                      = ['lib']

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/releases",
    'documentation_uri' => 'https://rubydoc.info/gems/repofetch',
    'source_code_uri' => 'https://github.com/spenserblack/repofetch',
    'github_repo' => 'ssh://github.com/spenserblack/repofetch',
    'rubygems_mfa_required' => 'true'
  }

  # TODO: Really seems like overkill to install this just for distance_of_time_in_words
  spec.add_runtime_dependency 'actionview', '~> 7.0', '>= 7.0.4'

  spec.add_runtime_dependency 'dotenv', '~> 2.8'
  spec.add_runtime_dependency 'faraday-retry', '~> 2.0'
  spec.add_runtime_dependency 'git', '~> 1.12'
  spec.add_runtime_dependency 'octokit', '~> 6.0', '>= 6.0.1'
  spec.add_runtime_dependency 'sawyer'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'os', '~> 1.1'
  spec.add_development_dependency 'overcommit', '~> 0.59'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.11'
  spec.add_development_dependency 'rspec-snapshot', '~> 2.0'
  spec.add_development_dependency 'rubocop', '~> 1.36'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.13'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'simplecov-cobertura', '~> 2.1'
  spec.add_development_dependency 'yard', '~> 0.9.28'
end
