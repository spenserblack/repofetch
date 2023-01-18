# frozen_string_literal: true

require 'action_view'
require 'octokit'
require 'optparse'
require 'repofetch/exceptions'
require 'repofetch/plugin'
require 'repofetch/util'

class Repofetch
  # Adds support for GitHub repositories.
  class Github < Repofetch::Plugin
    include ActionView::Helpers::NumberHelper
    include Repofetch::Util
    extend Repofetch::Util

    HTTP_REMOTE_REGEX = %r{https?://github\.com/(?<owner>[\w.-]+)/(?<repository>[\w.-]+)}.freeze
    SSH_REMOTE_REGEX = %r{git@github\.com:(?<owner>[\w.-]+)/(?<repository>[\w.-]+)}.freeze
    ASCII = File.read(File.expand_path('github/ASCII', __dir__))

    attr_reader :owner, :repository

    # Initializes the GitHub plugin.
    def initialize(owner, repository)
      super

      @owner = owner
      @repository = repository
      @client = Octokit::Client.new(access_token: ENV.fetch('GITHUB_TOKEN', nil))
    end

    def repo_id
      "#{@owner}/#{@repository}"
    end

    def stats
      stats = [http_clone_url, ssh_clone_url, stargazers, subscribers, forks, created, updated, size, issues,
               pull_requests]
      stats.each { |stat| stat.style_label!(:bold) }
    end

    # Detects that the repository is a GitHub repository.
    def self.matches_repo?(git)
      matches_remote?(default_remote_url(git))
    end

    # Detects that the remote URL is for a GitHub repository.
    def self.matches_remote?(remote)
      HTTP_REMOTE_REGEX.match?(remote) || SSH_REMOTE_REGEX.match?(remote)
    end

    # Gets the owner and repository from a GitHub local repository.
    def self.repo_identifiers(git)
      remote_identifiers(default_remote_url(git))
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
    #
    # @raise [Repofetch::PluginUsageError] if this plugin was selected *and* arguments were passed.
    def self.from_git(git, args)
      raise Repofetch::PluginUsageError, 'Explicitly activate this plugin to CLI arguments' unless args.empty?

      owner, repository = repo_identifiers(git)

      new(owner, repository)
    end

    # Creates an instance from CLI args and configuration.
    #
    # @raise [Repofetch::PluginUsageError] if +args+ couldn't be parsed.
    def self.from_args(args)
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: <plugin activation> -- [options] OWNER/REPOSITORY'
        opts.separator ''
        opts.separator 'This plugin can use the GITHUB_TOKEN environment variable increase rate limits'
      end
      parser.parse(args)
      split = args[0]&.split('/')

      raise Repofetch::PluginUsageError, parser.to_s unless split&.length == 2

      new(*split)
    end

    def header
      "#{theme.format(:bold, "#{owner}/#{repository}")} @ #{theme.format(:bold, 'GitHub')}"
    end

    def ascii
      ASCII
    end

    protected

    def repo_stats
      @repo_stats = @client.repository(repo_id) if @repo_stats.nil?
      @repo_stats
    end

    def http_clone_url
      Repofetch::Stat.new('HTTP(S)', repo_stats['clone_url'], emoji: '🌐')
    end

    def ssh_clone_url
      Repofetch::Stat.new('SSH', repo_stats['ssh_url'], emoji: '🔑')
    end

    def stargazers
      Repofetch::Stat.new('stargazers', repo_stats['stargazers_count'], emoji: '⭐')
    end

    def subscribers
      Repofetch::Stat.new('subscribers', repo_stats['subscribers_count'], emoji: '👀')
    end

    def forks
      Repofetch::Stat.new('forks', repo_stats['forks_count'], emoji: '🔱')
    end

    def created
      Repofetch::TimespanStat.new('created', repo_stats['created_at'], emoji: '🐣')
    end

    def updated
      Repofetch::TimespanStat.new('updated', repo_stats['updated_at'], emoji: '📤')
    end

    def size
      byte_size = number_to_human_size((repo_stats['size'] || 0) * 1024, precision: 2, significant: false,
                                                                         strip_insignificant_zeros: false)
      Repofetch::Stat.new('size', byte_size, emoji: '💽')
    end

    def issues
      @issue_search = @client.search_issues("repo:#{repo_id} is:issue", per_page: 1, page: 0) if @issue_search.nil?
      Repofetch::Stat.new('issues', @issue_search['total_count'], emoji: '❗')
    end

    def pull_requests
      @pr_search = @client.search_issues("repo:#{repo_id} is:pr", per_page: 1, page: 0) if @pr_search.nil?
      Repofetch::Stat.new('pull requests', @pr_search['total_count'], emoji: '🔀')
    end
  end
end

Repofetch::Github.register
