# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development do
  gem 'rake', '~> 13.0'
  gem 'rubocop', '~> 1.36'
  gem 'rubocop-rake', '~> 0.6'
  gem 'rubocop-rspec', '~> 2.13'
end

group :development, :test do
  gem 'rspec', '~> 3.11'
  gem 'simplecov', '~> 0.21', require: false
  gem 'simplecov-cobertura', '~> 2.1', require: false
end
