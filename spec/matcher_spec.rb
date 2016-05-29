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
end
