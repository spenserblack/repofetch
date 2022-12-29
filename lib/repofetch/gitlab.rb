# frozen_string_literal: true

require 'cgi'
require 'repofetch'

class Repofetch
  # Adds support for GitLab repositories.
  class Gitlab < Repofetch::Plugin
    attr_reader :repo_identifier

    # @param repo_identifier [String] The repository identifier (either the ID number or the namespaced repo name).
    def initialize(repo_identifier)
      super

      @repo_identifier = CGI.escape(repo_identifier)
    end

    def header
      # NOTE: Use `path_with_namespace`
      "#{@repo_identifier} @ GitLab"
    end

    def stats
      # NOTE: Use `name`
      [Repofetch::Stat.new('Hello', 'World')].each { |stat| %i[bold red].each { |style| stat.style_label!(style) } }
    end

    def ascii
      <<~ASCII
        HELLO
        WORLD
      ASCII
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
