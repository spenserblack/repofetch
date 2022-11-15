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
    def self.from_git(git)
      default_remote = Repofetch.default_remote(git)
      url = default_remote&.url
      match = HTTP_REMOTE_REGEX.match(url)
      match = SSH_REMOTE_REGEX.match(url) if match.nil?
      raise "Remote #{url.inspect} doesn't look like a GitHub remote" if match.nil?

      new(match[:owner], match[:repository])
    end

    # Creates an instance from CLI args.
    def self.from_args(args)
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: <plugin activation> -- [options] OWNER/REPOSITORY'
      end
      parser.parse(args)
      split = args[0]&.split('/')

      raise ArgumentError, parser.to_s unless split&.length == 2

      new(*split)
    end

    def header
      "#{@owner}/#{@repository} @ GitHub"
    end

    def ascii
      ASCII
    end
  end
end

Repofetch::GitHub.register
