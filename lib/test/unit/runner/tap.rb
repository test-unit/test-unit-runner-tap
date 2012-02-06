require 'test/unit'
require 'test/unit/runner/tap-version'

module Test
  module Unit
    AutoRunner.register_runner(:tap) do |auto_runner|
      require 'test/unit/ui/tap/testrunner'
      Test::Unit::UI::Tap::TestRunner
    end

    AutoRunner.register_runner(:tapj) do |auto_runner|
      require 'test/unit/ui/tapj/testrunner'
      TapUnit::TAPJ::TestRunner
    end

    AutoRunner.register_runner(:tapy) do |auto_runner|
      require 'test/unit/ui/tapy/testrunner'
      TapUnit::TAPY::TestRunner
    end
  end
end

# Copyright (c) 2012 Trans & Kouhei Sutou (LGPL v3.0)
