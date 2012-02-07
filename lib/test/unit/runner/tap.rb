require 'test/unit'
require 'test/unit/runner/tap-version'

module Test
  module Unit
    AutoRunner.register_runner(:tap) do |auto_runner|
      require 'test/unit/ui/tap/testrunner'
      Test::Unit::UI::Tap::TestRunner
    end

    AutoRunner.register_runner(:tapj) do |auto_runner|
      require 'test/unit/ui/tap/json_testrunner'
      Test::Unit::UI::Tap::JSONTestRunner
    end

    # alias for tap-j
    AutoRunner.register_runner(:json) do |auto_runner|
      require 'test/unit/ui/tap/json_testrunner'
      Test::Unit::UI::Tap::JSONTestRunner
    end

    AutoRunner.register_runner(:tapy) do |auto_runner|
      require 'test/unit/ui/tap/yaml_testrunner'
      Test::Unit::UI::Tap::YAMLTestRunner
    end

    # alias for tap-y
    AutoRunner.register_runner(:yaml) do |auto_runner|
      require 'test/unit/ui/tap/yaml_testrunner'
      Test::Unit::UI::Tap::YAMLTestRunner
    end

    # temporary, for testing difference between old and new
    AutoRunner.register_runner(:tap12) do |auto_runner|
      require 'test/unit/ui/tap/testrunner'
      Test::Unit::UI::Tap::TestRunner12
    end
  end
end

# Copyright (c) 2012 Trans & Kouhei Sutou (LGPL v3.0)
