# frozen_string_literal: true

class Repofetch
  # Provides uncategorized utilities.
  class Util
    # Cleans a string with style parameters (e.g. +"%{green}OK"+ -> +"OK"+)
    def self.clean_s(str)
      str.gsub(/%{[\w\d]+?}/, '')
    end

    # Removes ANSI escape sequences from +str+.
    def self.clean_ansi(str)
      str.gsub("\e", '').gsub(/\[\d+(;\d+)*m/, '')
    end
  end
end
