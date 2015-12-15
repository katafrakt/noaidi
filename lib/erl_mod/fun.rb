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

    private
  end
end
