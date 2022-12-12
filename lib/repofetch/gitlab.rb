# frozen_string_literal: true

require 'repofetch'

class Repofetch
  # Adds support for GitLab repositories.
  class Gitlab < Repofetch::Plugin
    attr_reader :repo_path

    def initialize(repo_path)
      super

      @repo_path = repo_path
    end

    def header
      "#{@repo_path} @ GitLab"
    end

    def stats
      [Repofetch::Stat.new('Hello', 'World')]
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
