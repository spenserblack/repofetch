# frozen_string_literal: true

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

  def self.clear_plugins
    @plugins = []
  end
  private_class_method :clear_plugins
end
