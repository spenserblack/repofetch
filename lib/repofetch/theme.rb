# frozen_string_literal: true

class Repofetch
  # Provides a theme for styling output.
  class Theme
    DEFAULT_STYLES = {
      black: 30,
      red: 31,
      green: 32,
      yellow: 33,
      blue: 34,
      magenta: 35,
      cyan: 36,
      white: 37,
      on_black: 40,
      on_red: 41,
      on_green: 42,
      on_yellow: 43,
      on_blue: 44,
      on_magenta: 45,
      on_cyan: 46,
      on_white: 47,
      bold: 1,
      underline: 4,
      reset: 0,
      default: 0
    }.freeze

    attr_reader :styles

    def initialize(styles = {})
      @styles = DEFAULT_STYLES.merge(styles)
    end

    # Gets the ANSI escape sequence for a style.
    def style(name)
      "\e[#{styles[name]}m"
    end

    # Formats a string with ANSI escape sequences.
    def format(name, text)
      "#{style(name)}#{text}#{style(:reset)}"
    end

    # Returns a Hash with ANSI escape sequences for each style.
    def to_h
      styles.transform_values { |value| "\e[#{value}m" }
    end
  end
end
