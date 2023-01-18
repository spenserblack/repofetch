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

    def to_s
      emoji = @emoji
      emoji = nil unless Repofetch.config.nil? || Repofetch.config.emojis?
      "#{emoji}#{format_label}: #{format_value}"
    end

    # Adds a style for the label
    #
    # @param [Symbol] style The theme's style to add
    def style_label!(style)
      @label_styles << style
    end

    # Formats the label, including styles.
    #
    # @return [String]
    def format_label
      return @label if @theme.nil?

      @label_styles.inject(@label) { |label, style| @theme.format(style, label) }
    end

    # Formats the value
    #
    # This simply converts the value to a string, but can be overridden but
    # subclasses to affect +to_s+.
    def format_value
      @value.to_s
    end
  end
end
