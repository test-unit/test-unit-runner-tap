# encoding: UTF-8

# TODO: I don't think that `test-unit-runner-tap` should be showing up
# in backtraces, it should be filtered out.

require 'stringio'
require 'test/unit/ui/tap/perl_testrunner'

class TestTap < Test::Unit::TestCase
  def test_run
    fail_line = nil
    test_case = Class.new(Test::Unit::TestCase) do
      def test_success
        assert_equal(3, 1 + 2)
      end

      def test_fail; assert_equal(3, 1 - 2); end; fail_line = __LINE__
    end
    output = StringIO.new
    runner = Test::Unit::UI::Tap::PerlTestRunner.new(test_case.suite, :output => output)
    result = runner.start; start_line = __LINE__
    assert_equal(<<-EOR, output.string.gsub(/[\d\.]+ seconds/, "0.001 seconds"))
1..2
not ok 1 - test_fail()
# FAIL (Test::Unit::Failure)
# <3> expected but was
# <-1>.
# test/test_tap.rb:17
#    15       end
#    16 
# => 17       def test_fail; assert_equal(3, 1 - 2); end; fail_line = __LINE__
#    18     end
#    19     output = StringIO.new
# test/test_tap.rb:21
ok 2 - test_success()
# Finished in 0.001 seconds.
# 2 tests, 2 assertions, 1 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
EOR
    assert_false(result.passed?)    # think this is correct, where as original runner had it wrong
  end
end

