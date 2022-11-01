# frozen_string_literal: true

LONG_DESCRIPTION = 'Fetches repository stats, like onefetch, but with a focus on the remote\'s stats'

Gem::Specification.new do |spec|
  spec.name                               = 'repofetch'
  spec.version                            = '0.4.0'
  spec.authors                            = ['Spenser Black']

  spec.summary                            = 'A plugin-based tool to fetch remote repository stats'
  spec.description                        = LONG_DESCRIPTION

  spec.homepage                           = 'https://github.com/spenserblack/repofetch'
  spec.license                            = 'MIT'

  spec.required_ruby_version              = Gem::Requirement.new('>= 2.6.0')

  spec.metadata['homepage_uri']           = spec.homepage
  spec.metadata['source_code_uri']        = 'https://github.com/spenserblack/repofetch'

  spec.files                              = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir                             = 'exe'
  spec.executables                        = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths                      = ['lib']

  spec.metadata['rubygems_mfa_required']  = 'true'

  spec.metadata['github_repo']            = 'ssh://github.com/spenserblack/repofetch'

  # TODO: Really seems like overkill to install this just for distance_of_time_in_words
  spec.add_runtime_dependency 'actionview', '~> 7.0', '>= 7.0.4'
end
