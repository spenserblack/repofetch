# frozen_string_literal: true

require 'repofetch'

class Repofetch
  # Adds support for Bitbucket repositories.
  class Bitbucket < Repofetch::Plugin
    ASCII = File.read(File.expand_path('bitbucket/ASCII', __dir__))

    def header
      'Bitbucket'
    end

    def stats
      stats = [Repofetch::Stat.new('URL', 'https://bitbucket.org', emoji: '🌐')]

      stats.each { |stat| %i[bold blue].each { |style| stat.style_label!(style) } }
    end

    def ascii
      ASCII
    end

    def self.matches_repo?(*)
      false
    end

    def self.from_git(*)
      new
    end

    def self.from_args(*)
      new
    end
  end
end

Repofetch::Bitbucket.register
