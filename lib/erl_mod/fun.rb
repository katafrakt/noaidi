module ErlMod
  ReturnContractViolation = Class.new(StandardError)

  class Fun
    def initialize(erl_mod, name, args, block)
      @module = erl_mod
      @name = name
      @args = args.map{|a| Matcher.new(a)}
      @block = block
    end

    def call(*args)
      freeze unless frozen?
      check_return_contract!(instance_exec(*args, &@block))
    end

    def matches?(args)
      return false unless arity == args.length
      args.each_with_index do |arg, i|
        return false unless @args[i].match?(arg)
      end
      true
    end

    def returns(contract, extension = nil)
      @return_contract = {contract: Matcher.new(contract), extension: extension}
    end

    def method_missing(name, *args)
      @module.public_send(name, *args)
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

      raise ReturnContractViolation unless @return_contract[:contract].match?(value)

      if @return_contract[:extension]
        raise ReturnContractViolation unless @return_contract[:extension].call(value)
      end

      value
    end
  end
end
