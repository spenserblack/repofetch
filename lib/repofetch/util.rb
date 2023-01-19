# frozen_string_literal: true

class Repofetch
  # Provides uncategorized utilities.
  module Util
    # Converts a format string into a plain string (e.g. +"%{green}OK"+ -> +"OK"+)
    def remove_format_params(str)
      str.gsub(/%{[\w\d]+?}/, '')
    end

    # Removes ANSI escape sequences from +str+.
    def clean_ansi(str)
      str.gsub("\e", '').gsub(/\[\d+(;\d+)*m/, '')
    end

    # Gets the name of the default remote to use.
    #
    # Will try to pick "origin", but if that is not found then it will
    # pick the first one found, or nil if there aren't any available.
    #
    # @param [Git::Base] git The repository instance.
    #
    # @return [Git::Remote]
    def default_remote(git)
      remotes = git.remotes
      found_remote = remotes.find { |remote| remote.name == 'origin' }
      found_remote = remotes[0] if found_remote.nil?
      found_remote
    end

    # Just wrapper around +default_remote+ since this is likely the most common
    # use case (and it's easier than referencing the +Git::Remote+ docs to ensure
    # correct usage in each plugin).
    #
    # @param [Git::Base] git The repository instance.
    #
    # @return [String]
    def default_remote_url(git)
      default_remote(git)&.url
    end
  end
end
