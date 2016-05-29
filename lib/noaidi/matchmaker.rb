module Noaidi
  def self.match(value, &block)
    compile_match(&block).call(value)
  end

  def self.compile_match(&block)
    Matchmaker.new(block)
  end

  class Matchmaker
    NoMatchError = Class.new(StandardError)

    def initialize(block)
      @branches = process_block(block)
    end

    def call(value)
      values = Array(value)
      @branches.each do |matchers, block|
        return block.call(*meaningful_values(matchers, values)) if matches?(matchers, values)
      end
      raise NoMatchError, "No match for #{@values.inspect}"
    end

    private
    def process_block(block)
      block.call(Parser.new)
    end

    def meaningful_values(matchers, values)
      values.zip(matchers).select do |i|
        value = i[0]
        matcher = i[1]
        !matcher.nil? && (matcher.pattern_class == Class || value.class != matcher.pattern_class)
      end.map{|i| i[0]}
    end

    def matches?(matchers, values)
      return false unless values.length == matchers.length
      values.each_with_index do |value, i|
        return false unless matchers[i].match?(value)
      end
      true
    end

    class Parser
      def call(*args, &block)
        @branches ||= {}
        key = args.map{ |i| Noaidi::Matcher.new(i) }
        @branches[key] = block
        @branches
      end
    end
    private_constant :Parser
  end
end
