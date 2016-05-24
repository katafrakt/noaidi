module Noaidi
  def self.match(value, branches)
    Matchmaker.new(value, branches).call
  end

  class Matchmaker
    NoMatchError = Class.new(StandardError)

    def initialize(value, branches)
      @values = Array(value)
      @branches = process_branches(branches)
    end

    def call
      @branches.each do |matchers, lbd|
        return lbd.call(*meaningful_values(matchers)) if matches?(matchers)
      end
      raise NoMatchError, "No match for #{@values.inspect}"
    end

    private
    def process_branches(branches)
      {}.tap do |hash|
        branches.each do |k,v|
          key = Array(k).map{|i| Noaidi::Matcher.new(i) }
          hash[key] = v
        end
      end
    end

    def meaningful_values(matchers)
      @values.zip(matchers).select do |i|
        value = i[0]
        matcher = i[1]
        !matcher.nil? && (matcher.pattern_class == Class || value.class != matcher.pattern_class)
      end.map{|i| i[0]}
    end

    def matches?(matchers)
      return false unless @values.length == matchers.length
      @values.each_with_index do |value, i|
        return false unless matchers[i].match?(value)
      end
      true
    end
  end
end
