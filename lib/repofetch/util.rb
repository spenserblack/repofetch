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
  end
end
