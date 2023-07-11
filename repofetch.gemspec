# frozen_string_literal: true

require_relative 'lib/repofetch/version'

LONG_DESCRIPTION = 'A plugin-based tool to fetch stats, with some git repository host stat fetchers included by default'

Gem::Specification.new do |spec|
  spec.name                               = 'repofetch'
  spec.version                            = Repofetch::VERSION
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
end
