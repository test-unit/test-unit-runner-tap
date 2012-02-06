require 'test/unit/runner/tap'

class TestExample < Test::Unit::TestCase
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

