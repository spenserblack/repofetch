# frozen_string_literal: true

require 'action_view'
require 'optparse'
require 'repofetch'
require 'repofetch/exceptions'
require 'sawyer'

class Repofetch
  # Adds support for Bitbucket repositories.
  class BitbucketCloud < Repofetch::Plugin
    include ActionView::Helpers::NumberHelper

    ASCII = File.read(File.expand_path('bitbucketcloud/ASCII', __dir__))

    attr_reader :repo_identifier

    def initialize(repo_identifier)
      super

      @repo_identifier = repo_identifier
    end

    def header
      "#{repo_data['owner']['display_name']}/#{repo_data['name']} @ Bitbucket"
    end

    def stats
      stats = [http_clone_url, ssh_clone_url, watchers, forks, created, updated, size, issues, pull_requests]

      stats.each { |stat| %i[bold blue].each { |style| stat.style_label!(style) } }
    end

    def ascii
      ASCII
    end

    def agent
      @agent ||= Sawyer::Agent.new('https://api.bitbucket.org/2.0') do |http|
        http.headers['Authorization'] = "Bearer #{token}" unless token.nil?
      end
    end

    def token
      ENV.fetch('BITBUCKET_TOKEN', nil)
    end

    def self.matches_repo?(*)
      false
    end

    def self.from_git(*)
      new
    end

    def self.from_args(args)
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: <plugin activation> -- [options] OWNER/PROJECT'
        opts.separator ''
        opts.separator 'This plugin can use the BITBUCKET_TOKEN environment variable'
      end
      parser.parse(args)

      raise Repofetch::PluginUsageError, parser.to_s unless args.length == 1

      new(args[0])
    end

    protected

    def repo_data
      @repo_data ||= agent.call(:get, "repositories/#{@repo_identifier}").data
    end

    def clone_urls
      @clone_urls ||= repo_data['links']['clone'].to_h { |clone| [clone['name'].to_sym, clone['href']] }
    end

    def http_clone_url
      Repofetch::Stat.new('HTTP(S)', clone_urls[:https], emoji: '🌐')
    end

    def ssh_clone_url
      Repofetch::Stat.new('SSH', clone_urls[:ssh], emoji: '🔑')
    end

    def watchers
      @watcher_data ||= agent.call(:get, "repositories/#{@repo_identifier}/watchers").data
      Repofetch::Stat.new('subscribers', @watcher_data['size'], emoji: '👀')
    end

    def forks
      @fork_data ||= agent.call(:get, "repositories/#{@repo_identifier}/forks").data
      Repofetch::Stat.new('forks', @fork_data['size'], emoji: '🔱')
    end

    def created
      Repofetch::TimespanStat.new('created', repo_data['created_on'], emoji: '🐣')
    end

    def updated
      Repofetch::TimespanStat.new('updated', repo_data['updated_on'], emoji: '📤')
    end

    def size
      # NOTE: Size is in bytes
      # TODO: Move this somewhere else instead of using a copy-paste
      byte_size = number_to_human_size(repo_data['size'] || 0, precision: 2, significant: false,
                                                               strip_insignificant_zeros: false)
      Repofetch::Stat.new('size', byte_size, emoji: '💽')
    end

    def issues
      @issue_data ||= agent.call(:get, "repositories/#{@repo_identifier}/issues").data
      Repofetch::Stat.new('issues', @issue_data['size'], emoji: '❗')
    end

    def pull_requests
      @pull_request_data ||= agent.call(:get, "repositories/#{@repo_identifier}/pullrequests").data
      Repofetch::Stat.new('pull requests', @pull_request_data['size'], emoji: '🔀')
    end
  end
end

Repofetch::BitbucketCloud.register
