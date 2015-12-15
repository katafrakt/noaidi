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
end
