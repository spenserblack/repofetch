# frozen_string_literal: true

require 'repofetch'
require 'repofetch/util'

class Repofetch
  # @abstract Subclass to create a plugin.
  class Plugin
    include Repofetch::Util

    # Plugin intializer arguments should come from the +from_git+ or +from_args+
    # class methods.
    def initialize(*) end

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

    # @abstract Detects that this plugin should be used. Should be overridden by subclasses.
    #
    # An example implementation is checking if +Repofetch.default_remote_url+ matches
    # a regular expression.
    #
    # @param [Git::Base] _git The Git repository object
    def self.matches_repo?(_git)
      raise NoMethodError, 'matches_repo? must be overridden by the plugin subclass'
    end

    # @abstract This should use a git instance and call +Plugin.new+.
    #
    # @param [Git::Base] _git The Git repository object to use when calling +Plugin.new+.
    # @param [Array] _args The arguments to process.
    #
    # @return [Plugin]
    def self.from_git(_git, _args)
      raise NoMethodError, 'from_git must be overridden by the plugin subclass'
    end

    # @abstract This will receive an array of strings (e.g. +ARGV+) and call +Plugin.new+.
    #
    # @param [Array] _args The arguments to process.
    #
    # @return [Plugin]
    def self.from_args(_args)
      raise NoMethodError, 'from_args must be overridden by the plugin subclass'
    end

    # Gets the plugin's theme. Override to use a theme besides the default.
    def theme
      Repofetch::DEFAULT_THEME
    end

    # @abstract The ASCII to be printed alongside the stats.
    #
    # This should be overridden by the plugin subclass.
    # Should be within the bounds 40x20 (width x height).
    def ascii
      raise NoMethodError, 'ascii must be overridden by the plugin subclass'
    end

    # @abstract The header to show for the plugin.
    #
    # This should be overridden by the plugin subclass.
    # For example, "foo/bar @ GitHub".
    def header
      raise NoMethodError, 'header must be overridden by the plugin subclass'
    end

    # Creates the separator that appears underneath the header
    def separator
      '-' * clean_ansi(header).length
    end

    def to_s
      zipped_lines.map do |ascii_line, stat_line|
        cleaned_ascii = clean_s(ascii_line)
        styled_ascii = (ascii_line % theme.to_h) + theme.style(:reset)
        aligned_stat_line = "#{' ' * (MAX_ASCII_WIDTH + 5)}#{stat_line}"
        "#{styled_ascii}#{aligned_stat_line.slice(cleaned_ascii.length..)}\n"
      end.join
    end

    # @abstract An array of stats that will be displayed to the right of the ASCII art.
    #
    # @return [Array<Stat>]
    def stats
      []
    end

    # Adds +theme+ to the stats, mutating those stats.
    #
    # @return [Array<Stat>]
    def theme_stats!
      stats.each do |stat|
        stat.theme = theme if stat.respond_to?(:theme=)
      end
    end

    # Makes an array of stat lines, including the header and separator.
    #
    # Mutates +stats+ to add the +theme+.
    def stat_lines!
      [header, separator, *theme_stats!.map(&:to_s)]
    end

    # Zips ASCII lines with stat lines.
    #
    # If there are more of one than the other, than the zip will be padded with empty strings.
    def zipped_lines
      ascii_lines = ascii.lines.map(&:chomp)
      stat_lines = stat_lines!
      if ascii_lines.length > stat_lines.length
        ascii_lines.zip(stat_lines)
      else
        stat_lines.zip(ascii_lines).map(&:reverse)
      end.map { |ascii, stat| [ascii.to_s, stat.to_s] }
    end
  end
end
