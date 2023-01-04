# frozen_string_literal: true

require 'git'
require 'optparse'
require 'repofetch'
require 'repofetch/config'
require 'repofetch/exceptions'

class Repofetch
  # Command line interface for repofetch.
  class CLI
    attr_reader :repository_path, :plugin

    # Define the command line interface.
    #
    # @param [Repofetch::Config] config The configuration to use. Defaults to +Repofetch.config+.
    # @param [Array<String>] args Command line arguments.
    def initialize(config = nil, args = ARGV)
      @config = config || Repofetch.config
      @args = args
      @repository_path = '.'
    end

    # Run the command line interface.
    #
    # @return [Integer] The exit code.
    def start
      load_plugins
      define_options.parse!(@args)

      begin
        plugin = new_plugin
      rescue Repofetch::PluginUsageError => e
        warn e
        return 1
      end

      puts plugin
      0
    end

    def define_options
      OptionParser.new do |opts|
        opts.banner = 'Usage: repofetch [options] -- [plugin arguments]'

        add_repository_options(opts)
        add_plugin_options(opts)
        add_options_notes(opts)
      end
    end

    def load_plugins
      @config.plugins.each { |plugin| require plugin }
    end

    def new_plugin
      return @plugin.from_args(@args) unless @plugin.nil?

      git = Git.open(@repository_path)
      Repofetch.get_plugin(git, @args)
    end

    private

    def add_repository_options(opts)
      opts.on('-r', '--repository', '-p', '--path PATH',
              'Use the provided path. Defaults to the current directory.') do |path|
        @repository_path = path
      end
    end

    def add_plugin_options(opts)
      opts.on('-P', '--plugin PLUGIN', 'Use the specified plugin.') do |plugin|
        @plugin = available_plugins[plugin]
      end

      Repofetch.plugins.each do |plugin|
        opts.on("--#{plugin.name.sub(/::/, '-').downcase}", "Shortcut for --plugin #{plugin.name}") do
          @plugin = plugin
        end
      end
    end

    def add_options_notes(opts)
      opts.separator ''
      dotenv_paths = Repofetch::Env.dotenv_paths.join(', ')
      opts.separator "The following dotenv files can be used to set environment variables: #{dotenv_paths}"
      opts.separator ''
      opts.separator "You config file is at #{Repofetch::Config.path}"
      opts.separator "Installed plugins: #{available_plugins.keys.join(', ')}"
    end

    def available_plugins
      Repofetch.plugins.to_h { |plugin| [plugin.name, plugin] }
    end
  end
end
