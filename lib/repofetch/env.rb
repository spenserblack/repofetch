# frozen_string_literal: true

require 'dotenv'

class Repofetch
  # Environment variable manager. Basically a wrapper around dotenv.
  class Env
    DOTENV_NAMES = ['repofetch.env', '.repofetch.env'].freeze
    DOTENV_PATHS = DOTENV_NAMES.map { |name| File.expand_path(name, Dir.home) }

    def self.load
      DOTENV_PATHS.each { |dotenv| Dotenv.load(dotenv) }
    end
  end
end
