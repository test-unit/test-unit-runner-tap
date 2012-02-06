require 'test/unit/ui/tap/abstract_testrunner'

module Test
  module Unit
    module UI
      module TapY

        # TAP-Y report format.
        class TestRunner < Tap::AbstractTestRunner
          def initialize(suite, options={})
            require 'yaml' unless respond_to?(:to_yaml)
            super(suite, options)
          end
          def tapout_before_suite(suite)
            puts super(suite).to_yaml
          end
          def tapout_before_case(testcase)
            doc = super(testcase)
            puts doc.to_yaml if doc
          end
          def tapout_note(note)
            doc = super(note)
            puts doc.to_yaml if doc
          end
          def tapout_pass(test)
            doc = super(test)
            puts doc.to_yaml if doc
          end
          def tapout_fail(test)
            doc = super(test)
            puts doc.to_yaml if doc
          end
          def tapout_omit(test)
            doc = super(test)
            puts doc.to_yaml if doc
          end
          def tapout_todo(test)
            doc = super(test)
            puts doc.to_yaml if doc
          end
          def tapout_error(test)
            doc = super(test)
            puts doc.to_yaml if doc
          end
          def tapout_after_suite(time)
            doc = super(time)
            puts doc.to_yaml if doc
            puts "..."
            puts
          end
        end

      end #module TAPY
    end #module UI
  end #module Unit
end #module Test
