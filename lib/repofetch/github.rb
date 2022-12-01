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
      matches_remote?(url)
    end

    # Detects that the remote URL is for a GitHub repository.
    def self.matches_remote?(remote)
      HTTP_REMOTE_REGEX.match?(remote) || SSH_REMOTE_REGEX.match?(remote)
    end

    # Gets the owner and repository from a GitHub local repository.
    def self.repo_identifiers(git)
      default_remote = Repofetch.default_remote(git)
      url = default_remote&.url
      remote_identifiers(url)
    end

    # Gets the owner and repository from a GitHub remote URL.
    #
    # Returns nil if there is no match.
    def self.remote_identifiers(remote)
      match = HTTP_REMOTE_REGEX.match(remote)
      match = SSH_REMOTE_REGEX.match(remote) if match.nil?
      raise "Remote #{remote.inspect} doesn't look like a GitHub remote" if match.nil?

      [match[:owner], match[:repository].delete_suffix('.git')]
    end

    # Creates an instance from a +Git::Base+ instance.
    def self.from_git(git, args, _config)
      # TODO: Raise a better exception than ArgumentError
      raise ArgumentError, 'Explicitly activate this plugin to CLI arguments' unless args.empty?

      owner, repository = repo_identifiers(git)

      new(owner, repository)
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
