require 'test/unit/ui/testrunner'
require 'test/unit/ui/testrunnermediator'
require 'stringio'

module Test
  module Unit
    module UI
      module TAP

        #
        class AbstractTestRunner < Test::Unit::UI::TestRunner

          # TAP-Y/J Revision
          REVISION = 4

          #
          def initialize(suite, options={})
            super

            @output = @options[:output] || STDOUT

            @level = 0

            @_source_cache = {}
            @already_outputted = false
            @top_level = true

            @counts = Hash.new{ |h,k| h[k] = 0 }
          end

        private

          #
          def setup_mediator
            super

            #suite_name = @suite.to_s   # file name
            #suite_name = @suite.name if @suite.kind_of?(Module)

            #reset_output  # TODO: Should we do this up front?
          end

          #
          def attach_to_mediator
            @mediator.add_listener(Test::Unit::TestResult::FAULT,                &method(:tapout_fault))
            @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::STARTED,  &method(:tapout_before_suite))
            @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::FINISHED, &method(:tapout_after_suite))
            @mediator.add_listener(Test::Unit::TestCase::STARTED_OBJECT,         &method(:tapout_before_test))
            @mediator.add_listener(Test::Unit::TestCase::FINISHED_OBJECT,        &method(:tapout_pass))
            @mediator.add_listener(Test::Unit::TestSuite::STARTED_OBJECT,        &method(:tapout_before_case))
            @mediator.add_listener(Test::Unit::TestSuite::FINISHED_OBJECT,       &method(:tapout_after_case))
          end

          #
          # Before everything else.
          #
          def tapout_before_suite(result)
            @result = result
            @suite_start = Time.now

            doc = {
              'type'  => 'suite',
              'start' => @suite_start.strftime('%Y-%m-%d %H:%M:%S'),
              'count' => @suite.size,
              #'seed'  => #@suite.seed,  # no seed?
              'rev'   => REVISION
            }
            return doc
          end

          #
          # After everything else.
          #
          def tapout_after_suite(elapsed_time)
            doc = {
              'type' => 'final',
              'time' => elapsed_time, #Time.now - @suite_start,
              'counts' => {
                'total' => @counts[:total],
                'pass'  => @counts[:pass], #self.test_count - self.failures - self.errors - self.skips,
                'fail'  => @counts[:fail],
                'error' => @counts[:error],
                'omit'  => @counts[:omit],
                'todo'  => @counts[:todo], 
              } #,
              #'assertions' => {
              #   'total' => @result.assertion_count + @counts[:fail],
              #   'pass'  => @result.assertion_count,
              #   'fail'  => @counts[:fail]
              #}
            }
            return doc
          end

          #
          #
          #
          def tapout_before_case(testcase)
            return nil if testcase.test_case.nil? 

            doc = {
              'type'    => 'case',
              #'subtype' => '',
              'label'   => testcase.name,
              'level'   => @level
            }

            @level += 1

            return doc
          end

          #
          # After each case, decrement the case level.
          #
          def tapout_after_case(testcase)
            @level -= 1
          end

          #
          def tapout_before_test(test)
            @test_start = Time.now
            # set up stdout and stderr to be captured
            reset_output
          end

          #
          def tapout_fault(fault)
            case fault
            when Test::Unit::Pending
              tapout_todo(fault)
            when Test::Unit::Omission
              tapout_omit(fault)
            when Test::Unit::Notification
              tapout_note(fault)
            when Test::Unit::Failure
              tapout_fail(fault)
            else
              tapout_error(fault)
            end

            @already_outputted = true #if fault.critical?
          end

          #
          def tapout_note(note)
            doc = {
              'type' => 'note',
              'text' => note.message
            }
            return doc
          end

          #
          def tapout_pass(test)
            if @already_outputted
              @already_outputted = false
              return nil
            end

            @counts[:total] += 1
            @counts[:pass]  += 1

            name = test.name.sub(/\(.+?\)\z/, '')

            doc = {
              'type'        => 'test',
              #'subtype'     => '',
              'status'      => 'pass',
              #'setup': foo instance
              'label'       => name,
              #'expected' => 2
              #'returned' => 2
              #'file'     => test_file
              #'line'     => test_line
              #'source'   => source(test_file)[test_line-1].strip,
              #'snippet'  => code_snippet(test_file, test_line),
              #'coverage':
              #  file: lib/foo.rb
              #  line: 11..13
              #  code: Foo#*
              'time' => Time.now - @suite_start
            }

            doc.update(captured_output)

            return doc
          end

          #
          def tapout_todo(fault)
            @counts[:total] += 1
            @counts[:todo]  += 1

            file, line = location(fault.location)
            rel_file   = file.sub(Dir.pwd+'/', '')

            doc = {
              'type'        => 'test',
              #'subtype'     => '',
              'status'      => 'todo',
              'label'       => fault.test_name.sub(/\(.+?\)\z/, ''),
              #'setup' => "foo instance",
              #'expected' => 2,
              #'returned' => 1,
              #'file'     => test_file
              #'line'     => test_line
              #'source'   => source(test_file)[test_line-1].strip,
              #'snippet'  => code_snippet(test_file, test_line),
              #'coverage' =>
              #  'file' => lib/foo.rb
              #  'line' => 11..13
              #  'code' => Foo#*
              'exception' => {
                'message'   => clean_message(fault.message),
                'class'     => fault.class.name,
                'file'      => rel_file,
                'line'      => line,
                'source'    => source(file)[line-1].strip,
                'snippet'   => code_snippet(file, line),
                'backtrace' => filter_backtrace(fault.location)
              },
              'time' => Time.now - @suite_start
            }

            doc.update(captured_output)

            return doc
          end

          #
          def tapout_omit(fault)
            @counts[:total] += 1
            @counts[:omit]  += 1

            file, line = location(fault.location)
            rel_file   = file.sub(Dir.pwd+'/', '')

            doc = {
              'type'        => 'test',
              #'subtype'     => '',
              'status'      => 'skip',
              'label'       => fault.test_name.sub(/\(.+?\)\z/, ''),
              #'setup' => "foo instance",
              #'expected' => 2,
              #'returned' => 1,
              #'file'     => test_file
              #'line'     => test_line
              #'source'   => source(test_file)[test_line-1].strip,
              #'snippet'  => code_snippet(test_file, test_line),
              #'coverage' =>
              #  'file' => lib/foo.rb
              #  'line' => 11..13
              #  'code' => Foo#*
              'exception' => {
                'message'   => clean_message(fault.message),
                'class'     => fault.class.name,
                'file'      => rel_file,
                'line'      => line,
                'source'    => source(file)[line-1].strip,
                'snippet'   => code_snippet(file, line),
                'backtrace' => filter_backtrace(fault.location)
              },
              'time' => Time.now - @suite_start
            }

            doc.update(captured_output)

            return doc
          end

          #
          def tapout_fail(fault)
            @counts[:total] += 1
            @counts[:fail]  += 1

            file, line = location(fault.location)
            rel_file = file.sub(Dir.pwd+'/', '')

            doc = {
              'type'        => 'test',
              #'subtype'     => '',
              'status'      => 'fail',
              'label'       => fault.test_name.sub(/\(.+?\)\z/, ''),
              #'setup' => "foo instance",
              'expected'    => fault.inspected_expected,
              'returned'    => fault.inspected_actual,
              #'file' => test_file
              #'line' => test_line
              #'source' => ok 1, 2
              #'snippet' =>
              #  - 44: ok 0,0
              #  - 45: ok 1,2
              #  - 46: ok 2,4
              #'coverage' =>
              #  'file' => lib/foo.rb
              #  'line' => 11..13
              #  'code' => Foo#*
              'exception' => {
                'message'   => clean_message(fault.user_message || fault.message),
                'class'     => fault.class.name,
                'file'      => rel_file,
                'line'      => line,
                'source'    => source(file)[line-1].strip,
                'snippet'   => code_snippet(file, line),
                'backtrace' => filter_backtrace(fault.location)
              },
              'time' => Time.now - @suite_start
            }

            doc.update(captured_output)

            return doc
          end

          #
          def tapout_error(fault)
            @counts[:total] += 1
            @counts[:error] += 1

            file, line = location(fault.location)
            rel_file = file.sub(Dir.pwd+'/', '')

            doc = {
              'type'        => 'test',
              #'subtype'     => '',
              'status'      => 'error',
              'label'       => fault.test_name.sub(/\(.+?\)\z/, ''),
              #'setup' => "foo instance",
              #'expected'    => fault.inspected_expected,
              #'returned'    => fault.inspected_actual,
              #'file' => test_file
              #'line' => test_line
              #'source' => ok 1, 2
              #'snippet' =>
              #  - 44: ok 0,0
              #  - 45: ok 1,2
              #  - 46: ok 2,4
              #'coverage' =>
              #  'file' => lib/foo.rb
              #  'line' => 11..13
              #  'code' => Foo#*
              'exception' => {
                'message'   => clean_message(fault.message),
                'class'     => fault.class.name,
                'file'      => rel_file,
                'line'      => line,
                'source'    => source(file)[line-1].strip,
                'snippet'   => code_snippet(file, line),
                'backtrace' => filter_backtrace(fault.location)
              },
              'time' => Time.now - @suite_start
            }

            doc.update(captured_output)

            return doc
          end

          # Clean the backtrace of any reference to test framework itself.
          def filter_backtrace(backtrace)
            trace = backtrace

            ## remove backtraces that match any pattern in $RUBY_IGNORE_CALLERS
            #trace = race.reject{|b| $RUBY_IGNORE_CALLERS.any?{|i| i=~b}}

            ## remove `:in ...` portion of backtraces
            trace = trace.map do |bt| 
              i = bt.index(':in')
              i ? bt[0...i] :  bt
            end

      # TODO: does TestUnit have a filter ?
            ## now apply MiniTest's own filter (note: doesn't work if done first, why?)
            #trace = MiniTest::filter_backtrace(trace)

            ## if the backtrace is empty now then revert to the original
            trace = backtrace if trace.empty?

            ## simplify paths to be relative to current workding diectory
            trace = trace.map{ |bt| bt.sub(Dir.pwd+File::SEPARATOR,'') }

            return trace
          end

          # Returns a String of source code.
          def code_snippet(file, line)
            s = []
            if File.file?(file)
              source = source(file)
              radius = 2 # TODO: make customizable (number of surrounding lines to show)
              region = [line - radius, 1].max ..
                       [line + radius, source.length].min

              s = region.map do |n|
                {n => source[n-1].chomp}
              end
            end
            return s
          end

          # Cache source file text. This is only used if the TAP-Y stream
          # doesn not provide a snippet and the test file is locatable.
          def source(file)
            @_source_cache[file] ||= (
              File.readlines(file)
            )
          end

          # Parse source location from caller, caller[0] or an Exception object.
          def parse_source_location(caller)
            case caller
            when Exception
              trace  = caller.backtrace.reject{ |bt| bt =~ INTERNALS }
              caller = trace.first
            when Array
              caller = caller.first
            end
            caller =~ /(.+?):(\d+(?=:|\z))/ or return ""
            source_file, source_line = $1, $2.to_i
            return source_file, source_line
          end

          # Get location of exception.
          def location(backtrace)
            last_before_assertion = ""
            backtrace.reverse_each do |s|
              break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
              last_before_assertion = s
            end
            file, line = last_before_assertion.sub(/:in .*$/, '').split(':')
            line = line.to_i if line
            return file, line
          end

          #
          def clean_message(message)
            message.strip.gsub(/\n+/, "\n")
          end

          #
          def puts(string="\n")
            @output.write(string)
            @output.flush      
          end

          #
          def reset_output
            @_oldout = $stdout
            @_olderr = $stderr

            @_newout = StringIO.new
            @_newerr = StringIO.new

            $stdout = @_newout
            $stderr = @_newerr
          end

          #
          def captured_output
            stdout = @_newout.string.chomp("\n")
            stderr = @_newerr.string.chomp("\n")

            doc = {}
            doc['stdout'] = stdout unless stdout.empty?
            doc['stderr'] = stderr unless stderr.empty?

            $stdout = @_oldout
            $stderr = @_olderr

            return doc
          end

        end

      end #module TAP
    end #module UI
  end #module Unit
end #module Test





=begin
    # TEMPORARILY LEAVING THIS FOR REFERENCE. What's this about encoding?

    def output_fault_message(fault)
      if fault.expected.respond_to?(:encoding) and
          fault.actual.respond_to?(:encoding) and
          fault.expected.encoding != fault.actual.encoding
        need_encoding = true
      else
        need_encoding = false
      end
      output(fault.user_message) if fault.user_message
      output_single("<")
      output_single(fault.inspected_expected, color("pass"))
      output_single(">")
      if need_encoding
        output_single("(")
        output_single(fault.expected.encoding.name, color("pass"))
        output_single(")")
      end
      output(" expected but was")
      output_single("<")
      output_single(fault.inspected_actual, color("failure"))
      output_single(">")
      if need_encoding
        output_single("(")
        output_single(fault.actual.encoding.name, color("failure"))
        output_single(")")
      end
      output("")

      from, to = prepare_for_diff(fault.expected, fault.actual)
      if from and to
        from_lines = from.split(/\r?\n/)
        to_lines = to.split(/\r?\n/)
        if need_encoding
          from_lines << ""
          to_lines << ""
          from_lines << "Encoding: #{fault.expected.encoding.name}"
          to_lines << "Encoding: #{fault.actual.encoding.name}"
        end
        differ = ColorizedReadableDiffer.new(from_lines, to_lines, self)
        if differ.need_diff?
          output("")
          output("diff:")
          differ.diff
        end
      end
    end
=end

