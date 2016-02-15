require 'test/unit/ui/tap/base_testrunner'

module Test
  module Unit
    module UI
      module Tap
        class Tap::BaseTestRunner < Test::Unit::UI::TestRunner

          def tapout_pass_with_source_location(test)
            doc = tapout_pass_without_source_location(test)
            if(doc && doc['type'] == 'test')
              file, _ = test.class.instance_method(clean_label(test.name).to_sym).source_location
              doc['file'] = file.sub(Dir.pwd+'/', '')
            end
            doc
          end

          def tapout_todo_with_source_location(fault)
            doc = tapout_todo(fault)
            doc['file'] = extract_source_location
            doc
          end

          def tapout_omit_with_source_location(fault)
            doc = tapout_omit_without_source_location(fault)
            doc['file'] = extract_source_location(fault) if doc
            doc
          end

          def tapout_fail_with_source_location(fault)
            doc = tapout_fail_without_source_location(fault)
            doc['file'] = extract_source_location(fault) if doc
            doc
          end

          def tapout_error_with_source_location(fault)
            doc =  tapout_error_without_source_location(fault)
            doc['file'] = extract_source_location(fault) if doc
            doc
          end

          alias_method :tapout_pass_without_source_location, :tapout_pass
          alias_method :tapout_pass, :tapout_pass_with_source_location
          alias_method :tapout_omit_without_source_location, :tapout_omit
          alias_method :tapout_omit, :tapout_omit_with_source_location
          alias_method :tapout_fail_without_source_location, :tapout_fail
          alias_method :tapout_fail, :tapout_fail_with_source_location
          alias_method :tapout_error_without_source_location, :tapout_error
          alias_method :tapout_error, :tapout_error_with_source_location
          alias_method :tapout_todo_without_source_location, :tapout_todo
          alias_method :tapout_todo, :tapout_todo_with_source_location

          private
            def extract_source_location(fault)
              file, _ = location(fault.location)
              file.sub(Dir.pwd+'/', '')
            end
        end
      end
    end
  end
end
