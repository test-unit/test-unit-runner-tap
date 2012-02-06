task :default => :test

desc "run unit tests"
task :test do
  ruby("test/run-test.rb")
end

desc "build gem package"
task :gem => ['.ruby'] do
  sh 'gem build .gemspec'  
end

file '.ruby' => ['Profile', 'lib/test/unit/runner/tap-version.rb'] do
  sh 'dotruby source Profile'
end

# vim: syntax=Ruby

