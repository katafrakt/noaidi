require "noaidi/version"
require "noaidi/dsl"
require "noaidi/module"
require "noaidi/fun"
require "noaidi/matcher"
require "noaidi/matchmaker"
require "noaidi/idioms/match"

module Noaidi
  def self.module(&block)
    Noaidi::Module.new.tap do |mod|
      mod.instance_eval(&block)
      mod.freeze
    end
  end
end
