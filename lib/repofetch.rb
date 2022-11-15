# frozen_string_literal: true

require 'action_view'
require 'git'
require 'repofetch/config'
require 'repofetch/exceptions'

# Main class for repofetch
class Repofetch
  MAX_ASCII_WIDTH = 40
  MAX_ASCII_HEIGHT = 20
  @plugins = []

  class << self
    attr_reader :plugins
  end

  # Registers a plugin.
  #
  # @param [Plugin] plugin The plugin to register
  def self.register_plugin(plugin)
    @plugins << plugin
  end

  # Replaces an existing plugin. If the existing plugin does not exist,
  # then it registers the plugin instead.
  #
  # @param [Plugin] old The plugin to be replaced
  # @param [Plugin] new The new plugin
  def self.replace_or_register_plugin(old, new)
    index = @plugins.find_index(old)
    if index.nil?
      register_plugin(new)
    else
      @plugins[index] = new
      @plugins
    end
  end

  # Returns the plugin that should be used.
  # Raises a +Repofetch::NoPluginsError+ if no plugins are found.
  # Raises a +Repofetch::TooManyPluginsError+ if more than one plugin is found.
  #
  # @param [String] git An instance of +Git::Base+
  #
  # @returns [Plugin] A plugin to use.
  def self.get_plugin(git)
    available_plugins = @plugins.filter do |plugin_class|
      plugin_class.matches_repo?(git)
    rescue NoMethodError
      warn "#{plugin_class} Does not implement +matches_repo?+"
      false
    end
    raise NoPluginsError if available_plugins.empty?

    raise TooManyPluginsError if available_plugins.length > 1

    available_plugins[0].from_git(git)
  end

  # Gets the name of the default remote to use.
  #
  # Will try to pick "origin", but if that is not found then it will
  # pick the first one found, or nil if there aren't any available.
  #
  # @param [String] path The path to the repository.
  #
  # @returns [Git::Remote]
  def self.default_remote(git)
    remotes = git.remotes
    found_remote = remotes.find { |remote| remote.name == 'origin' }
    found_remote = remotes[0] if found_remote.nil?
    found_remote
  end

  # Just wrapper around +default_remote+ since this is likely the most common
  # use case (and it's easier than referencing the +Git::Remote+ docs to ensure
  # correct usage in each plugin).
  #
  # @param [String] path The path to the repository.
  #
  # @return [String]
  def self.default_remote_url(path)
    default_remote(path)&.url
  end

  # Base class for plugins.
  class Plugin
    attr_reader :stats

    # Plugin intializer arguments should come from the +from_git+ or +from_args+
    # class methods.
    def initialize(*)
      @stats = []
    end

    # Registers this plugin class for repofetch.
    def self.register
      Repofetch.register_plugin(self)
    end

    # Tries to replace another plugin. An example use case might be if this plugin
    # extends another registered plugin.
    #
    # @param [Plugin] old The plugin to replace
    def self.replace_or_register(old)
      Repofetch.replace_or_register_plugin(old, self)
    end

    # Detects that this plugin should be used. Should be overridden by subclasses.
    #
    # An example implementation is checking if +Repofetch.default_remote_url+ matches
    # a regular expression.
    #
    # @param [Git::Base] _git The Git repository object
    def self.matches_repo?(_git)
      raise NoMethodError, 'matches_repo? must be overridden by the plugin subclass'
    end

    # This should use a git instance and call +Plugin.new+.
    #
    # @param [Git::Base] _git The Git repository object to use when calling +Plugin.new+.
    #
    # @returns [Plugin]
    def self.from_git(_git)
      raise NoMethodError, 'from_git must be overridden by the plugin subclass'
    end

    # This will receive an array of strings (e.g. +ARGV+) and call +Plugin.new+.
    #
    # @param [Array] _args The arguments to process.
    #
    # @returns [Plugin]
    def self.from_args(_args)
      raise NoMethodError, 'from_args must be overridden by the plugin subclass'
    end

    # The ASCII to be printed alongside the stats.
    #
    # This should be overridden by the plugin subclass.
    # Should be within the bounds 40x20 (width x height).
    def ascii
      raise NoMethodError, 'ascii must be overridden by the plugin subclass'
    end

    # The header to show for the plugin.
    #
    # This should be overridden by the plugin subclass.
    # For example, "foo/bar @ GitHub".
    def header
      raise NoMethodError, 'header must be overridden by the plugin subclass'
    end

    def to_s
      head = header
      separator = '-' * head.length
      lines_with_ascii([head, separator, *@stats.map(&:to_s)])
    end

    # Combines lines with the plugin's ASCII for proper spacing.
    #
    # @param [Array] lines An array of strings
    #
    # @returns [String]
    def lines_with_ascii(lines)
      ascii_lines = ascii.lines.map(&:strip)
      zipped = ascii_lines.length > lines.length ? ascii_lines.zip(lines) : lines.zip(ascii_lines).map(&:reverse)

      # NOTE: to_s to convert nil to an empty string
      zipped.map { |ascii_line, line| "#{ascii_line.to_s.ljust(Repofetch::MAX_ASCII_WIDTH + 5)}#{line}\n" }.join
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
