# frozen_string_literal: true

require 'action_view'
require 'git'

# Main class for repofetch
class Repofetch
  @plugins = []
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

  # Gets the name of the default remote to use.
  #
  # Will try to pick "origin", but if that is not found then it will
  # pick the first one found, or nil if there aren't any available.
  #
  # @param [String] path The path to the repository.
  #
  # @returns [Git::Remote]
  def self.default_remote(path)
    git = Git.open(path)
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
    attr_reader :path, :stats

    # @param [String] path
    #
    # The path to the git repository. Should be provided by the binary.
    def initialize(path)
      @path = path
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
    def use?
      false
    end

    # The ASCII to be printed alongside the stats.
    #
    # This should be overridden by the plugin subclass.
    # Should be within the bounds 40x20 (width x height).
    def ascii
      <<~ASCII
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
