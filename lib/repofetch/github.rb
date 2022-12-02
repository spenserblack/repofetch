# frozen_string_literal: true

require 'action_view'
require 'octokit'
require 'optparse'
require 'repofetch'

class Repofetch
  # Adds support for GitHub repositories.
  class Github < Repofetch::Plugin
    include ActionView::Helpers::NumberHelper

    HTTP_REMOTE_REGEX = %r{https?://github\.com/(?<owner>[\w.\-]+)/(?<repository>[\w.\-]+)}.freeze
    SSH_REMOTE_REGEX = %r{git@github\.com:(?<owner>[\w.\-]+)/(?<repository>[\w.\-]+)}.freeze
    ASCII = File.read(File.expand_path('github/ASCII', __dir__))

    attr_reader :owner, :repository, :stats

    # Initializes the GitHub plugin.
    def initialize(owner, repository) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # TODO: Refactor instead of disabling rules?
      super

      @owner = owner
      @repository = repository
      @client = Octokit::Client.new(access_token: ENV.fetch('GITHUB_TOKEN', nil))

      repo_resp = @client.repository(repo_id)

      byte_size = number_to_human_size(
        (repo_resp['size'] || 0) * 1024,
        precision: 2,
        significant: false,
        strip_insignificant_zeros: false
      )

      @stats = [
        ['🌐', 'URL', repo_resp['clone_url'], Repofetch::Stat],
        ['⭐', 'stargazers', repo_resp['stargazers_count'], Repofetch::Stat],
        ['👀', 'subscribers', repo_resp['subscribers_count'], Repofetch::Stat],
        ['🔱', 'forks', repo_resp['forks_count'], Repofetch::Stat],
        ['🐣', 'created', repo_resp['created_at'], Repofetch::TimespanStat],
        ['📤', 'updated', repo_resp['updated_at'], Repofetch::TimespanStat],
        ['💽', 'size', byte_size, Repofetch::Stat]
      ].map { |emoji, label, value, cls| cls.new(label, value, emoji: emoji, theme: theme) }

      issue_search_resp = @client.search_issues("repo:#{repo_id} is:issue", per_page: 1, page: 0)
      @stats << Repofetch::Stat.new('issues', issue_search_resp['total_count'], emoji: '❗', theme: theme)

      pr_search_resp = @client.search_issues("repo:#{repo_id} is:pr", per_page: 1, page: 0)
      @stats << Repofetch::Stat.new('pull requests', pr_search_resp['total_count'], emoji: '🔀', theme: theme)
    end

    def repo_id
      "#{@owner}/#{@repository}"
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
        opts.separator ''
        opts.separator 'This plugin can use the GITHUB_TOKEN environment variable increase rate limits'
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

Repofetch::Github.register
