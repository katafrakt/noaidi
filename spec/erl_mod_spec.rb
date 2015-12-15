require 'spec_helper'

describe ErlMod do
  it 'returns correct value' do
    MyModule = ErlMod.define do
      fun :test do
        42
      end
    end
    expect(MyModule.test).to eq(42)
  end

  it 'raises with no block given' do
    expect{
      ErlMod.define do
        fun :test, [Integer]
      end}.to raise_error(ErlMod::NoBlockGiven)
  end

  context 'chooses the best method' do
    before(:all) do
      @mod = ErlMod.define do
        fun :test_value, [2] { 22 }
        fun :test_value, [1] { 11 }
        fun :test_class, [Integer] { 1 }
        fun :test_class, [String] { "1" }
        fun :test_range, [(1..4)] { "small" }
        fun :test_range, [(4..10)] { "medium" }
        fun :test_range, [Numeric] { "big" }
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
    mod = ErlMod.define do
      fun :with_ivar do
        @state = 'initial'
      end
    end

    expect{mod.with_ivar}.to raise_error(RuntimeError)
  end

  context 'return contract' do
    before(:all) do
      @mod = ErlMod.define do
        fun :with_contract, [Object] do |param|
          param
        end.returns(Integer)

        fun :with_precise_contract, [Object] do |param|
          param
        end.returns(Fixnum, ->(a) { a > 10 })
      end
    end

    context 'with simple contract' do
      it 'passes' do
        expect(@mod.with_contract(1)).to eq(1)
      end

      it 'raises exception' do
        expect{@mod.with_contract("1")}.to raise_error(ErlMod::ReturnContractViolation)
      end
    end

    context 'with complex contract' do
      it 'passes' do
        expect(@mod.with_precise_contract(11)).to eq(11)
      end

      it 'raises exception' do
        expect{@mod.with_precise_contract(8)}.to raise_error(ErlMod::ReturnContractViolation)
      end
    end
  end
end
