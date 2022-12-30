# frozen_string_literal: true

require 'cgi'
require 'repofetch'
require 'sawyer'

class Repofetch
  # Adds support for GitLab repositories.
  class Gitlab < Repofetch::Plugin
    ASCII = File.read(File.expand_path('gitlab/ASCII', __dir__))

    attr_reader :repo_identifier

    # @param repo_identifier [String] The repository identifier (either the ID number or the namespaced repo name).
    def initialize(repo_identifier)
      super

      @repo_identifier = CGI.escape(repo_identifier)
    end

    def header
      "#{repo_data['name_with_namespace']} @ GitLab"
    end

    def stats
      stats = [url, stars, forks, created, updated]

      # NOTE: Stats that require authentication
      stats.concat([open_issues]) unless token.nil?

      stats.each { |stat| %i[bold red].each { |style| stat.style_label!(style) } }
    end

    def ascii
      ASCII
    end

    def agent
      @agent ||= @agent = Sawyer::Agent.new('https://gitlab.com/api/v4',
                                            links_parser: Sawyer::LinkParsers::Simple.new) do |http|
        http.headers['Authorization'] = "Bearer #{token}" unless token.nil?
      end
    end

    def token
      ENV.fetch('GITLAB_TOKEN', nil)
    end

    def repo_data
      @repo_data ||= agent.call(:get, "projects/#{@repo_identifier}").data
    end

    def url
      Repofetch::Stat.new('URL', repo_data['http_url_to_repo'], emoji: '🌐')
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

    def self.from_git(*)
      false
    end

    def self.from_args(args)
      new(args[0])
    end
  end
end

Repofetch::Gitlab.register
