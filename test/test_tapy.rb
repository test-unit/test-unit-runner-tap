require 'test/unit'

class TapYTest < Test::Unit::TestCase

  def initialize(*args)
    super(*args)

    @stream = tap_stream_using_format('tapy')

    # These three documents are the unit tests, which can occur in any order.
    # There one that shoud have a status of `pass`, another of `fail` and the
    # third of `error`.
    @passing_test = @stream.find{ |d| d['type'] == 'test' && d['status'] == 'pass' }
    @failing_test = @stream.find{ |d| d['type'] == 'test' && d['status'] == 'fail' }
    @erring_test  = @stream.find{ |d| d['type'] == 'test' && d['status'] == 'error' }
  end

  def test_there_should_be_six_sections
    assert_equal 6, @stream.size
  end

  def test_first_document_should_be_suite
    assert_equal 'suite', @stream.first['type']
    assert_equal 2,       @stream.first['count']
  end

  def test_second_document_should_be_case
    assert_equal 'case',            @stream[1]['type']
    assert_equal 'ExampleTestCase', @stream[1]['label']
    assert_equal 0,                 @stream[1]['level']
  end

  def test_passing_test_should_have_correct_label
    assert_equal 'test_passing', @passing_test['label']
  end

  def test_failing_test_should_have_correct_label
    assert_equal "test_failing", @failing_test['label']
  end

  def test_failing_test_should_hash_correct_exception
    assert_equal "Test::Unit::Failure",    @failing_test['exception']['class']
    assert_equal "test.rb",                @failing_test['exception']['file']
    assert_equal 11,                       @failing_test['exception']['line']
    assert_equal "assert_equal('1', '2')", @failing_test['exception']['source']
  end

  def test_failing_test_should_have_test_unit_in_backtrace
    @failing_test['exception']['backtrace'].each do |e|
      assert_not_match /test\/unit/, e
    end
  end

  def test_erring_test_should_have_correct_label
    assert_equal 'test_error', @erring_test['label']
  end

  def test_erring_test_should_have_correct_exception
    assert_equal 'Test::Unit::Error', @erring_test['exception']['class']
    assert_equal 'test.rb',           @erring_test['exception']['file']
    assert_equal 7,                   @erring_test['exception']['line']
    assert_equal 'raise',             @erring_test['exception']['source']
  end

  def test_erring_test_should_not_mention_testunit_in_backtrace
    @erring_test['exception']['backtrace'].each do |e|
      assert_not_match /test\/unit/, e
    end
  end

  def test_last_should_be_a_final_document
    assert_equal 'final', @stream.last['type']
  end

  def test_should_have_prpoer_counts
    assert_equal 3, @stream.last['counts']['total']
    assert_equal 1, @stream.last['counts']['error']
    assert_equal 1, @stream.last['counts']['fail']
    assert_equal 1, @stream.last['counts']['pass']
    assert_equal 0, @stream.last['counts']['omit']
    assert_equal 0, @stream.last['counts']['todo']
  end

private

  FIXTURE = File.dirname(__FILE__) + '/fixtures'

  def tap_stream_using_format(type)
    output = `ruby -Ilib #{FIXTURE}/test_example.rb --runner #{type}`

    begin
      #@stream = YAML.load_documents(@out)  # b/c of bug in Ruby 1.8
      @stream = (
        s = []
        YAML.load_documents(output){ |d| s << d }
        s
      )
    rescue Exception
      puts output
      raise
    end
  end

end
