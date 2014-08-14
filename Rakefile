# vim: set ts=2 sw=2 ai et:
require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default)
rescue Exception => e
  puts '========================================================='
  puts e.message
  puts 'run `bundle install --path=~/.bundle` for a fresh install'
  puts ' or `bundle update` for an existing installation'
  puts '========================================================='
  exit
end

require 'rake'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb' # find and run all files via naming pattern
  t.rspec_opts = [
    '--require ./spec/spec_helper.rb', # all rspecs require spec_helper
    '--color', # colorize all rspec output
    '--format documentation', # use long output, not dots/splats/Fs
  ]
end
