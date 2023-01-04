# frozen_string_literal: true

class Repofetch
  class Error < RuntimeError
  end

  # Raised when there aren't any available plugins.
  class NoPluginsError < Error
  end

  # Raised when more than one plugin is activated.
  class TooManyPluginsError < Error
  end
end
