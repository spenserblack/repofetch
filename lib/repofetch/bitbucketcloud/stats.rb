# frozen_string_literal: true

require 'repofetch'

class Repofetch
  class BitbucketCloud < Repofetch::Plugin
    # Methods to get Bitbucket Cloud stats.
    module Stats
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
end
