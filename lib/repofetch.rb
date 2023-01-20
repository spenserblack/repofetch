# frozen_string_literal: true

require 'action_view'
require 'git'
require 'repofetch/config'
require 'repofetch/env'
require 'repofetch/exceptions'
require 'repofetch/plugin'
require 'repofetch/stat'
require 'repofetch/timespan_stat'
require 'repofetch/theme'
require 'repofetch/util'

# Main class for repofetch
class Repofetch
  MAX_ASCII_WIDTH = 40
  MAX_ASCII_HEIGHT = 20
  DEFAULT_THEME = Theme.new.freeze
  @plugins = []

  class << self
    attr_accessor :config
    attr_reader :plugins
  end

  # Loads the config, without affecting the file system.
  def self.load_config
    @config = Config.load
  end

  # Loads the config, writing a default config if it doesn't exist.
  def self.load_config!
    @config = Config.load!
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
  # @param [Git::Base] git A repository instance.
  # @param [Array<String>] args The arguments passed to the program.
  #
  # @raise [NoPluginsError] If no plugins were selected.
  # @raise [TooManyPluginsError] If more than one plugin was selected.
  #
  # @return [Plugin] A plugin to use.
  def self.get_plugin(git, args)
    available_plugins = @plugins.filter { |plugin_class| plugin_class.matches_repo?(git) }
    raise NoPluginsError if available_plugins.empty?

    raise TooManyPluginsError if available_plugins.length > 1

    available_plugins[0].from_git(git, args)
  end

  def self.clear_plugins
    @plugins = []
  end
  private_class_method :clear_plugins
end
