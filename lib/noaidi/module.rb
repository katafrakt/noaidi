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
      f = Fun.new(self, name, args, block)

      unless @funs.key?(name)
        define_fun_method(name)
        @funs[name] ||= []
      end

      @funs[name] << f
      f
    end

    def funp(*args, &block)
      f = fun(*args, &block)
      self.singleton_class.send(:private, f.name)
    end

    def inspect_funs
      @funs.inspect
    end

    private
    def define_fun_method(name)
      define_singleton_method(name) do |*args|
        fun = find_best_fun(name, args)
        if fun.nil?
          method_missing(name, *args)
        else
          fun.module.instance_exec(*args, &fun.block)
        end
      end
    end

    def find_best_fun(name, args)
      @funs[name].detect { |f| f.matches?(args) }
    end
  end
end
