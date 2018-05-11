require 'spec_helper'

RSpec.describe Noaidi::Matcher do
  Matcher = described_class

  it 'matches by value (integer)' do
    matcher = Matcher.new(1)
    expect(matcher.match?(1)).to eq(true)
    expect(matcher.match?(2)).to eq(false)
  end

  it 'matches by value (string)' do
    matcher = Matcher.new("aaa")
    expect(matcher.match?("aaa")).to eq(true)
    expect(matcher.match?("aaaa")).to eq(false)
  end

  it 'matches by class' do
    matcher = Matcher.new(Integer)

    expect(matcher.match?(1)).to eq(true)

    expect(matcher.match?('1')).to eq(false)
    expect(matcher.match?(1.1)).to eq(false)
    expect(matcher.match?(nil)).to eq(false)
    expect(matcher.match?([1])).to eq(false)
  end

  it 'matches by range' do
    matcher = Matcher.new(1..10)

    expect(matcher.match?(1)).to eq(true)
    expect(matcher.match?(10)).to eq(true)
    expect(matcher.match?(6)).to eq(true)
    expect(matcher.match?(1.3)).to eq(true)

    expect(matcher.match?(11)).to eq(false)
    expect(matcher.match?(0)).to eq(false)
    expect(matcher.match?('2')).to eq(false)
    expect(matcher.match?(2..6)).to eq(false)
  end

  it 'matches by flat Hash' do
    matcher = Matcher.new(a: 123, b: :symbol)

    expect(matcher.match?(a: 123, b: :symbol)).to eq(true)
    expect(matcher.match?(a: 123, b: :symbol, c: 442)).to eq(true)

    expect(matcher.match?(a: 125, b: :symbol)).to eq(false)
    expect(matcher.match?(a: 125)).to eq(false)
    expect(matcher.match?(b: :symbol)).to eq(false)
    expect(matcher.match?({})).to eq(false)

    expect(matcher.match?(123)).to eq(false)
  end

  it 'matches by nested Hash' do
    matcher = Matcher.new(a: Integer, b: {c: :ok, b: String})

    expect(matcher.match?(a: 12, b: {c: :ok, b: 'aaa'})).to eq(true)
    expect(matcher.match?(a: 12, b: {c: :ok, b: 'aaa', d: 78})).to eq(true)
    expect(matcher.match?(a: 12, test: false, b: {c: :ok, b: 'aaa', d: 78})).to eq(true)

    expect(matcher.match?(a: 12, b: {})).to eq(false)
    expect(matcher.match?(a: 12, b: {c: :ok})).to eq(false)
    expect(matcher.match?(a: 12, b: {c: :nok, b: 'abc'})).to eq(false)
    expect(matcher.match?(a: 12, b: {c: :ok, b: 123})).to eq(false)
    expect(matcher.match?(a: 'test', b: {c: :ok, b: 123})).to eq(false)
  end

  it 'respect guard (matches by lambda)' do
    matcher = Matcher.new(->(val) { val < 10 })

    expect(matcher.match?(1)).to eq(true)
    expect(matcher.match?(9.9)).to eq(true)

    expect(matcher.match?(10)).to eq(false)
    expect(matcher.match?(100)).to eq(false)

    expect(matcher.match?('123')).to eq(false)
  end
end
