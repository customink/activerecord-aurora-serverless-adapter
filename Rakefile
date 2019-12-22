require 'bundler/gem_tasks'
require 'rake/testtask'
require_relative 'test/support/aasa_paths'
require_relative 'test/support/aasa_rake'

namespace :test do

  %w(mysql).each do |mode|

    Rake::TestTask.new(mode) do |t|
      t.libs = AASA::Paths.test_load_paths
      t.test_files = AASA::Rake.test_files
      t.warning = !!ENV['WARNING']
      t.verbose = false
    end

  end

  task 'mysql:env' do
    ENV['ARCONN'] = 'mysql'
  end

end

task test: ['test:mysql']
task 'test:mysql' => 'test:mysql:env'
task default: [:test]
