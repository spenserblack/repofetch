# frozen_string_literal: true

require 'cgi'
require 'repofetch'
require 'repofetch/exceptions'
require 'sawyer'

class Repofetch
  # Adds support for GitLab repositories.
  class Gitlab < Repofetch::Plugin
    HTTP_REMOTE_REGEX = %r{https?://gitlab\.com/(?<path>[\w.-][\w.\-/]+)}
    SSH_REMOTE_REGEX = %r{git@gitlab\.com:(?<path>[\w.-][\w.\-/]+)}
    ASCII = File.read(File.expand_path('gitlab/ASCII', __dir__))

    attr_reader :repo_identifier

    # @param repo_identifier [String] The repository identifier (either the ID number or the namespaced repo name).
    def initialize(repo_identifier)
      super

      @repo_identifier = CGI.escape(repo_identifier)
    end

    def header
      "#{header_format(repo_data['name_with_namespace'])} @ #{header_format('GitLab')}"
    end

    def header_format(text)
      theme.format(:bold, theme.format(:red, text))
    end

    def stats
      stats = [http_clone_url, ssh_clone_url, stars, forks, created, updated]

      # NOTE: Stats that require authentication
      stats << open_issues unless token.nil?

      stats.each { |stat| %i[bold red].each { |style| stat.style_label!(style) } }
    end

    def ascii
      ASCII
    end

    def agent
      @agent ||= Sawyer::Agent.new('https://gitlab.com/api/v4', links_parser: Sawyer::LinkParsers::Simple.new) do |http|
        http.headers['Authorization'] = "Bearer #{token}" unless token.nil?
      end
    end

    def token
      ENV.fetch('GITLAB_TOKEN', nil)
    end

    def repo_data
      @repo_data ||= agent.call(:get, "projects/#{@repo_identifier}").data
    end

    def http_clone_url
      Repofetch::Stat.new('HTTP(S)', repo_data['http_url_to_repo'], emoji: '🌐')
    end

    def ssh_clone_url
      Repofetch::Stat.new('SSH', repo_data['ssh_url_to_repo'], emoji: '🔑')
    end

    def stars
      Repofetch::Stat.new('stars', repo_data['star_count'], emoji: '⭐')
    end

    def forks
      Repofetch::Stat.new('forks', repo_data['forks_count'], emoji: '🔱')
    end

    def created
      Repofetch::TimespanStat.new('created', repo_data['created_at'], emoji: '🐣')
    end

    def updated
      Repofetch::TimespanStat.new('updated', repo_data['last_activity_at'], emoji: '📤')
    end

    def open_issues
      # NOTE: It seems like the auth token must be set to get the open issues count.
      Repofetch::Stat.new('open issues', repo_data['open_issues_count'], emoji: '❗')
    end

    # Gets the path (+owner/subproject/repo+) of the repository.
    def self.repo_identifier(git)
      default_remote = Repofetch.default_remote(git)
      url = default_remote&.url
      remote_identifier(url)
    end

    # Gets the path (+owner/subproject/repo+) of the repository.
    #
    # Returns nil if there is no match.
    def self.remote_identifier(remote)
      match = HTTP_REMOTE_REGEX.match(remote)
      match = SSH_REMOTE_REGEX.match(remote) if match.nil?
      raise "Remote #{remote.inspect} doesn't look like a GitLab remote" if match.nil?

      match[:path].delete_suffix('.git')
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

    # Creates an instance from a +Git::Base+ instance.
    #
    # @raise [Repofetch::PluginUsageError] if this plugin was selected *and* arguments were passed.
    def self.from_git(git, args)
      raise Repofetch::PluginUsageError, 'Explicitly activate this plugin to CLI arguments' unless args.empty?

      path = repo_identifier(git)

      new(path)
    end

    def self.from_args(args)
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: <plugin activation> -- [options] OWNER/PROJECT/SUBPROJECT'
        opts.separator ''
        opts.separator 'This plugin can use the GITLAB_TOKEN environment variable to fetch more data'
      end
      parser.parse(args)

      raise Repofetch::PluginUsageError, parser.to_s unless args.length == 1

      new(args[0])
    end
  end
end

Repofetch::Gitlab.register
