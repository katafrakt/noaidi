module ErlMod
  ReturnContractViolation = Class.new(StandardError)

  class Fun
    def initialize(name, args, block)
      @name = name
      @args = args
      @block = block
    end

    def call(*args)
      freeze unless frozen?
      check_return_contract!(instance_exec(*args, &@block))
    end

    def matches?(args)
      return false unless arity == args.length
      args.each_with_index do |arg, i|
        return false unless @args[i] === arg
      end
      true
    end

    def returns(contract, extension = nil)
      @return_contract = {contract: contract, extension: extension}
    end

    private
    def arity
      @args.length
    end

    def arguments
      @args
    end

    def check_return_contract!(value)
      return value unless @return_contract

      raise ReturnContractViolation unless @return_contract[:contract] === value

      if @return_contract[:extension]
        raise ReturnContractViolation unless @return_contract[:extension].call(value)
      end

      value
    end
  end
end
