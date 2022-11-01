# frozen_string_literal: true

require 'action_view'

# Main class for repofetch
class Repofetch
  @plugins = []
  # Registers a plugin.
  #
  # @param [Plugin] plugin The plugin to register
  def self.register_plugin(plugin)
    @plugins << plugin
  end

  # Base class for plugins.
  class Plugin
    # Registers this plugin class for repofetch.
    def self.register
      Repofetch.register_plugin(self)
    end
  end

  # Base class for stats.
  class Stat
    attr_reader :label, :value, :emoji

    # Creates a stat
    #
    # @param [String] label The label of the stat
    # @param value The value of the stat
    # @param [String] emoji An optional emoji for the stat
    def initialize(label, value, emoji: nil)
      @label = label
      @value = value
      @emoji = emoji
    end

    def to_s
      "#{@emoji || ''}#{@label}: #{@value}"
    end

    # Formats the value
    #
    # This simply converts the value to a string, but can be overridden but
    # subclasses to affect +to_s+.
    def format_value
      @value.to_s
    end
  end

  # Timespan stat for "x units ago" stats.
  class TimespanStat < Stat
    include ActionView::Helpers::DateHelper

    # Formats the value as "x units ago".
    def format_value(now = 0)
      "#{distance_of_time_in_words(@value, now)} ago"
    end
  end

  def self.clear_plugins
    @plugins = []
  end
  private_class_method :clear_plugins
end
