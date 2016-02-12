require "noaidi/version"
require "noaidi/dsl"
require "noaidi/module"
require "noaidi/fun"
require "noaidi/matcher"
require "noaidi/matchmaker"

module Noaidi
  def self.module(&block)
    Noaidi::Module.new.tap do |mod|
      mod.instance_eval(&block)
    end
  end
end
