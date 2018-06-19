require "noaidi/version"
require "noaidi/dsl"
require "noaidi/fun"
require "noaidi/matcher"
require "noaidi/matchmaker"
require "noaidi/idioms/match"

module Noaidi
  def self.module(&block)
    ::Module.new do
      extend Noaidi::DSL

      instance_eval(&block)
      freeze
    end
  end
end
