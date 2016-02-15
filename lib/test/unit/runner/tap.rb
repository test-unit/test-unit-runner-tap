require 'test-unit'
require 'test/unit/runner/tap-version'
require 'test/unit/ui/tap/ext/base_testrunner'

module Test
  module Unit
    AutoRunner.register_runner(:tap) do |auto_runner|
      require 'test/unit/ui/tap/perl_testrunner'
      Test::Unit::UI::Tap::PerlTestRunner
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

    # temporaryily available as fallback to orignal tap runner
    # just in case the new runner exhibits any issues
    AutoRunner.register_runner(:tap0) do |auto_runner|
      require 'test/unit/ui/tap/perl_testrunner'
      Test::Unit::UI::Tap::OldTestRunner
    end
  end
end

# Copyright (c) 2012 Trans & Kouhei Sutou (LGPL v3.0)
