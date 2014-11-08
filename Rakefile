task :default => :test

desc "run unit tests"
task :test do
  ruby("test/run-test.rb")
end

desc "prepare for release"
task :prep => ['.index'] do
  sh 'mast -u'
end

desc "build gem package"
task :gem => :prep do
  sh 'gem build .gemspec'  
end

file '.index' => ['Index.rb', 'lib/test/unit/runner/tap-version.rb'] do
  sh 'index -u Index.rb'
end

# vim: syntax=Ruby

