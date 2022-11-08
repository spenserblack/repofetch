# frozen_string_literal: true

require 'action_view'
require 'git'
require 'repofetch/exceptions'

# Main class for repofetch
class Repofetch
  PLACEHOLDER_ASCII = <<~ASCII
    REPOFETCHREPOFETCHREPOFETCHREPOFETCH
    REPOFETCHREPOFETCHREPOFETCHREPOFETCH
    RE                                CH
    RE                                CH
    RE                                CH
    RE                                CH
    RE                                CH
    RE                                CH
    RE                                CH
    RE                                CH
    RE  the plugin creator forgot to  CH
    RE    define their own ascii!!    CH
    RE                                CH
    RE                                CH
    RE                                CH
    RE                                CH
    RE                                CH
    RE                                CH
    RE                                CH
    REPOFETCHREPOFETCHREPOFETCHREPOFETCH
    REPOFETCHREPOFETCHREPOFETCHREPOFETCH
  ASCII

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
    available_plugins = @plugins.filter { |plugin_class| plugin_class.matches_repo?(git) }
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

    # Plugin intializer arguments should come from either the CLI or from the +use+
    # class method.
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
      false
    end

    # This should use a git instance and call +Plugin.new+.
    #
    # @param [Git::Base] _git The Git repository object to use when calling +Plugin.new+.
    #
    # @returns [Plugin]
    def self.from_git(_git)
      new
    end

    # This will receive an array of strings (e.g. +ARGV+) and call +Plugin.new+.
    #
    # @param [Array] _args The arguments to process.
    #
    # @returns [Plugin]
    def self.from_args(_args)
      new
    end

    # The ASCII to be printed alongside the stats.
    #
    # This should be overridden by the plugin subclass.
    # Should be within the bounds 40x20 (width x height).
    def ascii
      Repofetch::PLACEHOLDER_ASCII
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
