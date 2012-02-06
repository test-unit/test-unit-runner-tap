require 'tapunit/tapy'

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

  def test_failure
    assert_equal(3, 1)
  end

  def test_error
    raise ArgumentError, "it did not go so well"
  end

  def test_output
    puts "You should see me."
    assert_equal(1,1)
  end

  def teardown
    @number = nil
  end
end
