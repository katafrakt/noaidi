require 'spec_helper'

describe 'Noaidi with plain module' do
  module TestMath
    extend Noaidi::DSL

    fun(:fib, 0..1) { 1 }
    fun(:fib, Integer) do |n|
      add(fib(n-1), fib(n-2))
    end
    fun(:fib, String) { puts 'This works only for integers' }

    funp(:add, Integer, Integer) do |a,b|
      a + b
    end
  end

  it 'calculates fib for 0' do
    expect(TestMath.fib(0)).to eq(1)
  end

  it 'calculates fib for 1' do
    expect(TestMath.fib(0)).to eq(1)
  end

  it 'calculates fib for 20' do
    expect(TestMath.fib(20)).to eq(10946)
  end

  it 'raises on attempt to call private fun' do
    expect do
      TestMath.add(1, 3)
    end.to raise_error(NoMethodError, /private method `add' called for TestMath/)
  end
end
