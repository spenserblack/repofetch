# frozen_string_literal: true

require 'repofetch/stat'

class Repofetch
  # Timespan stat for "x units ago" stats.
  class TimespanStat < Stat
    include ActionView::Helpers::DateHelper

    # Formats the value as "x units ago".
    def format_value(now = nil)
      now = Time.now if now.nil?
      "#{distance_of_time_in_words(@value, now)} ago"
    end
  end
end
