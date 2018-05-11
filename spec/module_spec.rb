require 'spec_helper'

describe Noaidi::Module do
  Spy = Class.new

  it 'returns correct value' do
    MyModule = Noaidi.module do
      fun :test do
        42
      end
    end
    expect(MyModule.test).to eq(42)
  end

  it 'raises with no block given' do
    expect{
      Noaidi.module do
        fun :test, [Integer]
      end}.to raise_error(Noaidi::NoBlockGiven)
  end

  context 'chooses the best method' do
    before(:all) do
      @mod = Noaidi.module do
        fun(:test_value, 2) { 22 }
        fun(:test_value, 1) { 11 }
        fun(:test_class, Integer) { 1 }
        fun(:test_class, String) { "1" }
        fun(:test_range, (1..4)) { "small" }
        fun(:test_range, (4..10)) { "medium" }
        fun(:test_range, Numeric) { "big" }
      end
    end

    context 'by value' do
      it '1' do
        expect(@mod.test_value(1)).to eq(11)
      end

      it '2' do
        expect(@mod.test_value(2)).to eq(22)
      end
    end

    context 'by class' do
      it 'string' do
        expect(@mod.test_class("aaa")).to eq("1")
      end

      it 'integer' do
        expect(@mod.test_class(17)).to eq(1)
      end
    end

    context 'by range' do
      it 'small' do
        expect(@mod.test_range(2)).to eq("small")
      end

      it 'medium' do
        expect(@mod.test_range(7)).to eq("medium")
      end

      it 'medium float' do
        expect(@mod.test_range(7.5)).to eq("medium")
      end

      it 'big' do
        expect(@mod.test_range(15)).to eq("big")
      end

      it 'big float' do
        expect(@mod.test_range(15.5)).to eq("big")
      end
    end
  end

  it 'disallows using instance variables' do
    mod = Noaidi.module do
      fun :with_ivar do
        @state = 'initial'
      end
    end

    expect{mod.with_ivar}.to raise_error(RuntimeError)
  end

  context 'calling methods from same module' do
    before(:all) do
      @mod = Noaidi.module do
        fun(:fib, 0) { 0 }
        fun(:fib, 1) { 1 }
        fun(:fib, Integer) do |n|
          fib(n - 1) + fib(n - 2)
        end
      end
    end

    it 'allows to call' do
      expect(@mod.fib(8)).to eq(21)
    end
  end

  context 'private funs' do
    before do
      @mod = Noaidi.module do
        fun(:public_fun) { private_fun }
        funp(:private_fun) { Spy.call }
      end
    end

    it 'allows calling private methods from public ones' do
      expect(Spy).to receive(:call)
      @mod.public_fun
    end

    it 'disallows calling private methods from outside' do
      expect { @mod.private_fun }.to raise_error(NoMethodError, /private method `private_fun' called/)
    end
  end

  context 'any method' do
    before(:all) do
      @mod = Noaidi.module do
        fun(:id, any) { |x| x }
      end
    end

    it 'string' do
      expect(@mod.id("aaa")).to eq("aaa")
    end

    it 'integer' do
      expect(@mod.id(2137)).to eq(2137)
    end

    it 'array' do
      expect(@mod.id([1,2,3])).to eq([1,2,3])
    end
  end
end
