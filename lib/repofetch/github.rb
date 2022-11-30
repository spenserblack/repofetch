# frozen_string_literal: true

require 'optparse'
require 'repofetch'

class Repofetch
  # Adds support for GitHub repositories.
  class GitHub < Repofetch::Plugin
    HTTP_REMOTE_REGEX = %r{https?://github\.com/(?<owner>[\w.\-]+)/(?<repository>[\w.\-]+)}.freeze
    SSH_REMOTE_REGEX = %r{git@github\.com:(?<owner>[\w.\-]+)/(?<repository>[\w.\-]+)}.freeze
    ASCII = File.read(File.expand_path('github/ASCII', __dir__))

    attr_reader :owner, :repository

    # Initializes the GitHub plugin.
    def initialize(owner, repository)
      super

      @owner = owner
      @repository = repository
    end

    # Detects that the repository is a GitHub repository.
    def self.matches_repo?(git)
      default_remote = Repofetch.default_remote(git)
      url = default_remote&.url
      HTTP_REMOTE_REGEX.match?(url) || SSH_REMOTE_REGEX.match?(url)
    end

    # Creates an instance from a +Git::Base+ instance.
    def self.from_git(git, args, _config)
      # TODO: Raise a better exception than ArgumentError
      raise ArgumentError, 'Explicitly activate this plugin to CLI arguments' unless args.empty?

      default_remote = Repofetch.default_remote(git)
      url = default_remote&.url
      match = HTTP_REMOTE_REGEX.match(url)
      match = SSH_REMOTE_REGEX.match(url) if match.nil?
      raise "Remote #{url.inspect} doesn't look like a GitHub remote" if match.nil?

      new(match[:owner], match[:repository])
    end

    # Creates an instance from CLI args and configuration.
    def self.from_args(args, _config)
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: <plugin activation> -- [options] OWNER/REPOSITORY'
      end
      parser.parse(args)
      split = args[0]&.split('/')

      # TODO: Raise a better exception than ArgumentError
      raise ArgumentError, parser.to_s unless split&.length == 2

      new(*split)
    end

    def header
      "#{theme.format(:bold, "#{owner}/#{repository}")} @ #{theme.format(:bold, 'GitHub')}"
    end

    def ascii
      ASCII
    end
  end
end

Repofetch::GitHub.register
