module Noaidi
  class Matcher
    def initialize(pattern)
      @pattern = pattern
    end

    def match?(value)
      @pattern === value
    end

    def pattern_class
      @pattern.class
    end
  end
end
