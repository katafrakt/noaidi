module Noaidi
  NoBlockGiven = Class.new(StandardError)

  class Module
    include Noaidi::DSL

    def initialize
      @funs = {}
    end

    def fun(*args, &block)
      raise NoBlockGiven unless block_given?
      name = args.shift.to_sym
      fun = Fun.new(self, name, args, block)

      unless @funs.key?(name)
        define_fun_method(name)
        @funs[name] ||= []
      end

      @funs[name] << fun
      fun
    end

    def inspect_funs
      @funs.inspect
    end

    def define_fun_method(name)
      self.class.define_method(name) do |*args|
        fun = find_best_fun(name, args)
        if fun.nil?
          method_missing(name, *args)
        else
          fun.call(*args)
        end
      end
    end

    private
    def find_best_fun(name, args)
      @funs[name].detect { |f| f.matches?(args) }
    end
  end
end
