# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../app/report_builder'

class ReportBuilderTest < Minitest::Test
  def test_happy_path
    ReportBuilder.call('test/fixtures/data_short.csv.gz', "result.json")
    assert(File.exist?("result.json"))
    f = File.read("result.json")
    parsed = JSON.parse(f)
    assert(parsed.has_key?("totalUsers"))
    assert(parsed.has_key?("totalSessions"))
    assert(parsed.has_key?("uniqueBrowsersCount"))
    assert(parsed.has_key?("allBrowsers"))
    assert(parsed.has_key?("usersStats"))
    assert(parsed["usersStats"].is_a?(Array))
    parsed["usersStats"].each do |user_report|
      assert(user_report.has_key?('id'))
      assert(user_report.has_key?('firstName'))
      assert(user_report.has_key?('lastName'))
      assert(user_report.has_key?('alwaysUsedChrome'))
      assert(user_report.has_key?('browsers'))
      assert(user_report.has_key?('longestSession'))
      assert(user_report.has_key?('totalTime'))
    end
  end


  def test_no_file
    assert_raises(ArgumentError) { ReportBuilder.call("unexisting_file.csv") }
  end


  def teardown
    File.delete("result.json") if File.exist?("result.json")
  end
end
