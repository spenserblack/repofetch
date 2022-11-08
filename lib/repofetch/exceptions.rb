# frozen_string_literal: true

# Raised when there aren't any available plugins.
class Repofetch
  class Error < RuntimeError
  end

  class NoPluginsError < Error
  end

  class TooManyPluginsError < Error
  end
end
