#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/lib/test/unit/runner/tap-version'

name    "test-unit-runner-tap"
version Test::Unit::Runner::Tap::VERSION
title   "TestUnit TAP"
summary "TAP runners for TestUnit."

description "This project provides TAP and TAP-Y/J test output formats for the TestUnit test framework."

authors [
  'Thomas Sawyer <transfire@gmail.com>',
  'Kouhei Sutou <kou@cozmixng.org>'
]

requirements [
  'test-unit',
  'rake (build)',
  'mast (build)',
  'indexer (build)'
]

resources(
  'home' => 'https://github.com/test-unit/test-unit-runner-tap',
  'code' => 'https://github.com/test-unit/test-unit-runner-tap'
)

copyrights [
  '2012 Thomas Sawyer (GPL-2)',
  '2012 Kouhei Sutou  (GPL-2)'
]

