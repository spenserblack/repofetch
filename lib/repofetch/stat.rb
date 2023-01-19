# frozen_string_literal: true

class Repofetch
  # Base class for stats.
  class Stat
    attr_reader :label, :value, :emoji
    attr_writer :theme

    # Creates a stat
    #
    # @param [String] label The label of the stat
    # @param value The value of the stat
    # @param [String] emoji An optional emoji for the stat
    def initialize(label, value, emoji: nil)
      @label = label
      @value = value
      @emoji = emoji
      @label_styles = []
    end

    def format(theme = nil)
      return to_s if theme.nil?

      emoji = @emoji
      emoji = nil unless Repofetch.config.nil? || Repofetch.config.emojis?
      styled_label = @label_styles.inject(@label) { |label, style| theme.format(style, label) }
      "#{emoji}#{styled_label}: #{format_value}"
    end

    # Formats the value of the stat
    #
    # Simply calls +to_s+, but can be overridden by subclasses.
    def format_value
      @value.to_s
    end

    def to_s
      emoji = @emoji
      emoji = nil unless Repofetch.config.nil? || Repofetch.config.emojis?
      "#{emoji}#{@label}: #{@value}"
    end

    # Adds a style for the label
    #
    # @param [Symbol] style The theme's style to add
    def style_label!(style)
      @label_styles << style
    end
  end
end
