require_relative 'internal_dsl'

module Noaidi
  NoBlockGiven = Class.new(StandardError)
  VisibilityMismatchError = Class.new(StandardError)

  module DSL
    include ::Noaidi::Internal::DSL

    def fun(*args, &block)
      add_fun(args: args, visibility: :public, &block)
    end

    def funp(*args, &block)
      f = add_fun(args: args, visibility: :private, &block)
      self.singleton_class.send(:private, f.name)
    end

    private

    def _funs
      @funs ||= {}
    end

    def add_fun(args:, visibility:, &block)
      raise NoBlockGiven unless block_given?
      name = args.shift.to_sym
      check_visibility!(name, visibility)

      f = Fun.new(self, name, args, block)
      f.set_visibility!(visibility)

      unless _funs.key?(name)
        define_fun_method(name)
        _funs[name] ||= []
      end

      _funs[name] << f
      f
    end

    def check_visibility!(name, visibility)
      previous_definition = _funs[name]
      return if previous_definition.nil?

      previous_definition = previous_definition.first

      if previous_definition.visibility != visibility
        the_other = visibility == :public ? :private : :public
        raise VisibilityMismatchError.new("#{name} has already been defined as #{the_other}")
      end
    end

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
      _funs[name].detect { |f| f.matches?(args) }
    end
  end
end
