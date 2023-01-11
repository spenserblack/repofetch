# frozen_string_literal: true

require 'optparse'
require 'repofetch'
require 'repofetch/exceptions'
require 'sawyer'

class Repofetch
  # Adds support for Bitbucket repositories.
  class BitbucketCloud < Repofetch::Plugin
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
      stats = [Repofetch::Stat.new('URL', 'https://bitbucket.org', emoji: '🌐')]

      stats.each { |stat| %i[bold blue].each { |style| stat.style_label!(style) } }
    end

    def ascii
      ASCII
    end

    def agent
      @agent ||= Sawyer::Agent.new('https://api.bitbucket.org/2.0',
                                   links_parser: Sawyer::LinkParsers::Simple.new) do |http|
        http.headers['Authorization'] = "Bearer #{token}" unless token.nil?
      end
    end

    def token
      ENV.fetch('BITBUCKET_TOKEN', nil)
    end

    def repo_data
      @repo_data ||= agent.call(:get, "repositories/#{@repo_identifier}").data
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
  end
end

Repofetch::BitbucketCloud.register
