# To be done
require 'spec_helper'

describe Noaidi::Matchmaker do
  include Noaidi::DSL
  include Noaidi::Idioms::Match

  it 'returns 2' do
    re = match 1 do |m|
      m.(Integer) { |i| i + 1 }
      m.(Array, BasicObject) { |i,j| "nope" }
    end
    expect(re).to eq(2)
  end

  it 'returns string' do
    re = match [:error, 2] do |m|
      m.(Integer) { 1 }
      m.(:error, Integer) { |i| "nope #{i}" }
    end
    expect(re).to be_kind_of(String)
  end
end
