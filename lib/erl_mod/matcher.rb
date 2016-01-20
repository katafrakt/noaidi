module ErlMod
  class Matcher
    def initialize(pattern)
      @pattern = pattern
    end

    def match?(value)
      @pattern === value
    end
  end
end
