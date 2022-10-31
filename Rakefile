# frozen_string_literal: true

require 'bundler/setup'
require 'rake'

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:format) do |t|
  t.requires << 'rubocop-rspec'
end

desc 'Run tests'
task default: %i[format spec]
