module Noaidi
  class Matcher
    def initialize(pattern)
      @pattern = pattern
    end

    def match?(value)
      case @pattern
      when Proc
        match_with_lambda(value)
      when Hash
        match_with_hash(value)
      else
        @pattern === value
      end
    end

    def pattern_class
      @pattern.class
    end

    private

    # TODO: compile it at construction time
    def match_with_hash(value)
      return false unless value.is_a?(Hash)

      @pattern.map do |key, val|
        Matcher.new(val).match?(value[key])
      end.all?{ |x| x == true }
    end

    def match_with_lambda(value)
      @pattern.call(value)
    end
  end
end
