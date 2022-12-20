# frozen_string_literal: true

require 'bundler/setup'
require 'rake'

require 'os'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = if OS.windows?
                   '--exclude-pattern spec/**/*_unix_spec.rb'
                 else
                   '--exclude-pattern spec/**/*_windows_spec.rb'
                 end
end
RuboCop::RakeTask.new(:format) do |t|
  t.requires << 'rubocop-rspec'
end
YARD::Rake::YardocTask.new(:doc)

desc 'Run tests'
task default: %i[format spec]
