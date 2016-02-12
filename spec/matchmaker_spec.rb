# To be done
require 'spec_helper'

describe Noaidi::Matchmaker do
  include Noaidi::DSL

  it 'returns 2' do
    re = Noaidi.match 1, {
      Integer => ->(i) { i + 1 },
      [Array, BasicObject] => ->(i,j) { "nope" }
    }
    expect(re).to eq(2)
  end

  it 'returns string' do
    re = Noaidi.match [:error, 2], {
      Integer => proc { 1 },
      [:error, Integer] => ->(i) { "nope #{i}" }
    }
    expect(re).to be_kind_of(String)
  end
end
