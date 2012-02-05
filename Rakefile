task :default => :test

desc "run unit tests"
task :test do
  ruby("test/run-test.rb")
end

desc "build gem package"
task :gem => ['.ruby'] do
  sh 'gem build .gemspec'  
end

file '.ruby' do
  sh 'dotruby source Profile'
end

# vim: syntax=Ruby

