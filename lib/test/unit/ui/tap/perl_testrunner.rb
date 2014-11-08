require 'test/unit/ui/testrunner'
require 'test/unit/ui/testrunnermediator'
require 'test/unit/ui/tap/base_testrunner'

module Test
  module Unit
    module UI
      module Tap

        # Outputs test results in traditional TAP format, version 12.
        #
        class PerlTestRunner < BaseTestRunner
          #
          def tapout_before_suite(suite)
            doc = super(suite)
            @i = 0
            puts "1..#{doc['count']}"
          end

          #
          def tapout_pass(test)
            doc = super(test)
            if doc
              @i += 1
              puts "ok #{@i} - #{doc['label']}(#{@test_case.name})"
            end
          end

          #
          def tapout_fail(fault)
            doc = super(fault)
            if doc
              @i += 1
              puts "not ok #{@i} - #{doc['label']}(#{@test_case.name})"
              puts subdata(doc, 'FAIL')
            end
          end

          #
          def tapout_error(fault)
            doc = super(fault)
            if doc
              @i += 1
              puts "not ok #{@i} - #{doc['label']}(#{@test_case.name})"
              puts subdata(doc, 'ERROR')
            end
          end

          #
          def tapout_omit(fault)
            doc = super(fault)
            if doc
              @i += 1
              puts "not ok #{@i} - #{doc['label']}(#{@test_case.name})  # SKIP"
              puts subdata(doc, 'SKIP')
            end
          end

          #
          def tapout_todo(fault)
            doc = super(fault)
            if doc
              @i += 1
              puts "not ok #{@i} - #{doc['label']}(#{@test_case.name})  # TODO"
              puts subdata(doc, 'TODO')
            end
          end

          #
          def tapout_note(note)
            doc = super(note)
            puts '# ' + doc['text'].gsub("\n", "\n# ")
          end

          #
          def tapout_after_suite(time)
            puts("# Finished in #{time} seconds.")
            @result.to_s.each_line do |line|
              puts("# #{line}")
            end
          end

        private

          # TODO: Should this use test-unit's `fault.long_display`?

          #
          def subdata(doc, type)
            exp       = doc['exception']
            exp_class = exp['class']
            message   = exp['message']
            backtrace = exp['backtrace']
            file      = exp['file']
            line      = exp['line']

            body = []
            body << "%s (%s)" % [type, exp_class]
            body << message.to_s

            backtrace[0..0].each do |bt|
              body << bt.to_s
            end

            code_snippet_string(file, line).each_line do |s|
              body << s.chomp
            end

            backtrace[1..-1].each do |bt|
              body << bt.to_s
            end

            body = body.join("\n").gsub(/^/, '# ')
          end

        end

        # TestUnit's original TAP testrunner.
        #
        # We keep this runner for the time being as a fallback as the new
        # code matures.
        #
        class OldTestRunner < UI::TestRunner
          def initialize(suite, options={})
            super
            @output = @options[:output] || STDOUT
            @n_tests = 0
            @already_outputted = false
          end

          private
          def attach_to_mediator
            @mediator.add_listener(TestResult::FAULT, &method(:add_fault))
            @mediator.add_listener(TestRunnerMediator::STARTED, &method(:started))
            @mediator.add_listener(TestRunnerMediator::FINISHED, &method(:finished))
            @mediator.add_listener(TestCase::STARTED, &method(:test_started))
            @mediator.add_listener(TestCase::FINISHED, &method(:test_finished))
          end

          def add_fault(fault)
            puts("not ok #{@n_tests} - #{fault.short_display}")
            fault.long_display.each_line do |line|
              puts("# #{line}")
            end
            @already_outputted = true
          end

          def started(result)
            @result = result
            puts("1..#{@suite.size}")
          end

          def finished(elapsed_time)
            puts("# Finished in #{elapsed_time} seconds.")
            @result.to_s.each_line do |line|
              puts("# #{line}")
            end
          end

          def test_started(name)
            @n_tests += 1
          end

          def test_finished(name)
            unless @already_outputted
              puts("ok #{@n_tests} - #{name}")
            end
            @already_outputted = false
          end

          def puts(*args)
            @output.puts(*args)
            @output.flush
          end
        end

      end
    end
  end
end

# Copyright (c) 2012 Trans & Kouhei Sutou (LGPL v3.0)
