gem 'test-unit'
require 'test-unit'
#require 'test/unit/runner/tap'
require 'active_support'
require 'active_support/test_case'

class TestExample < ActiveSupport::TestCase
  def setup
    @number = 5
  end

  def test_add
    assert_equal(7, @number + 2, "Should have added correctly")
  end

  def test_subtract
    assert_equal(3, @number - 2, "Should have subtracted correctly")
  end

  def teardown
    @number = nil
  end
end

