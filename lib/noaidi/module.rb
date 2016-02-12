module Noaidi
  NoBlockGiven = Class.new(StandardError)

  class Module
    include Noaidi::DSL
    
    def initialize
      @funs = {}
    end

    def fun(name, args=[], &block)
      raise NoBlockGiven unless block_given?
      name = name.to_sym
      f = Fun.new(self, name, args, block)
      @funs[name] ||= []
      @funs[name] << f
      f
    end

    def inspect_funs
      @funs.inspect
    end

    def method_missing(name, *args)
      find_best_method(name, args).call(*args)
    end

    private
    def find_best_method(name, args)
      @funs[name].detect { |f| f.matches?(args) }
    end
  end
end
