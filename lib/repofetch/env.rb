# frozen_string_literal: true

require 'dotenv'

class Repofetch
  # Environment variable manager. Basically a wrapper around dotenv.
  class Env
    DOTENV_NAMES = ['repofetch.env', '.repofetch.env'].freeze

    def self.load
      dotenv_paths.each { |dotenv| Dotenv.load(dotenv) }
    end

    def self.dotenv_paths
      DOTENV_NAMES.map { |name| File.expand_path(name, Dir.home) }
    end
  end
end
