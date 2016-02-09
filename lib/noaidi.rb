require "noaidi/version"
require "noaidi/module"
require "noaidi/fun"
require "noaidi/matcher"

module Noaidi
  def self.module(&block)
    Noaidi::Module.new.tap do |mod|
      mod.instance_eval(&block)
    end
  end
end
