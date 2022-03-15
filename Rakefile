# Rakefile
require 'rake/testtask'
require_relative 'app/report_builder'


Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end


task :default => [:test]

task :build_report, [:source_gzipped_file, :result_json_file] do |_t, args|
  source_gzipped_file = args[:source_gzipped_file]
  result_json_file = args[:result_json_file] || "result.json"
  ReportBuilder.call(source_gzipped_file, result_json_file)
end