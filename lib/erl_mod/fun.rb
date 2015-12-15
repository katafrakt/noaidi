module ErlMod
  class Fun
    def initialize(name, args, block)
      @name = name
      @args = args
      @block = block
    end

    def call(*args)
      @block.call(*args)
    end

    def arity
      @args.length
    end

    def matches?(args)
      return false unless arity == args.length
      args.each_with_index do |arg, i|
        return false unless @args[i] === arg
      end
      true
    end

    private
  end
end
