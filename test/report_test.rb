# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../app/report'
require_relative '../app/user'
require_relative '../app/session'

class ReporTest < Minitest::Test
  USER_ARGS = [499_999, 'Sammy', 'Ronald', 39].freeze
  SECOND_USER_ARGS = [4, 'Corie', 'Erika', 32].freeze
  SESSION_ARGS = [499_999, 8, 'Firefox 33', 49, '2017-06-28'].freeze
  SECOND_SESSION_ARGS = [499_999, 0, 'Chrome 32', 93, '2016-06-14'].freeze

  def setup
    @report = Report.new

    @user = User.new(*USER_ARGS)
    @second_user = User.new(*SECOND_USER_ARGS)
    @session = Session.new(*SESSION_ARGS)
    @second_session = Session.new(*SECOND_SESSION_ARGS)
  end

  def test_register_user_stores_user_and_increments_counter
    # ensure all is empty
    assert(@report.users_counter.zero?)
    assert(@report.users_by_id[499_999].nil?)

    @report.register_user(@user)

    # ensure user registered
    assert(@report.users_by_id[499_999] == @user)
    assert(@report.users_counter == 1)

    @report.register_user(@user)
    # ensure user not registered twice
    assert(@report.users_counter == 1)
  end

  def test_register_session_stores_session_to_user_and_increments_counters
    # register user before
    @report.register_user(@user)

    # ensure all is empty
    assert(@report.sessions_counter.zero?)
    assert(@report.users_by_id[499_999].sessions == [])

    # register session
    @report.register_session(@session)

    # ensure session is registered and counter incremented
    assert(@report.users_by_id[499_999].sessions.last == @session)
    assert(@report.sessions_counter == 1)
  end

  def test_register_session_causes_error_if_user_with_such_id_doesnt_exist_yet
    assert_raises(RuntimeError) { @report.register_session(@session) }
  end

  def test_result_returns_hash_with_predefined_keys
    @report.register_user(@user)
    @report.register_session(@session)
    result = @report.result

    assert(result.is_a?(Hash))
    %i[
      totalUsers
      totalSessions
      uniqueBrowsersCount
      allBrowsers
      usersStats
    ].each do |key|
      assert(result.key?(key))
    end

    users_stats = result[:usersStats]
    assert(users_stats.length == 1)
    user_stat = users_stats.first

    assert user_stat[:id] == @user.id
    assert user_stat[:firstName] == @user.first_name
    assert user_stat[:lastName] == @user.last_name
    assert user_stat[:totalTime] == @session.time
    assert user_stat[:longestSession] == @session.time
    assert user_stat[:browsers] == @session.browser.upcase
    assert user_stat[:usedIE] == false
    assert user_stat[:alwaysUsedChrome] == false
  end

  def test_result_calculates_proper_stats_for_each_user
    @report.register_user(@user)
    @report.register_user(@second_user)
    @report.register_session(@session)
    @report.register_session(@second_session)

    result = @report.result

    assert(result.is_a?(Hash))
    %i[
      totalUsers
      totalSessions
      uniqueBrowsersCount
      allBrowsers
      usersStats
    ].each do |key|
      assert(result.key?(key))
    end

    users_stats = result[:usersStats]
    assert(users_stats.length == 2)
    first_user_stat = users_stats.find { |s| s[:id] == @user.id }

    assert first_user_stat[:firstName] == @user.first_name
    assert first_user_stat[:lastName] == @user.last_name
    assert first_user_stat[:totalTime] == @session.time + @second_session.time
    assert first_user_stat[:longestSession] == @second_session.time
    assert first_user_stat[:browsers] == 'FIREFOX 33, CHROME 32'
    assert first_user_stat[:usedIE] == false
    assert first_user_stat[:alwaysUsedChrome] == false

    second_user_stat = users_stats.find { |s| s[:id] == @second_user.id }
    assert second_user_stat[:firstName] == @second_user.first_name
    assert second_user_stat[:lastName] == @second_user.last_name
    assert (second_user_stat[:totalTime]).zero?
    assert (second_user_stat[:longestSession]).zero?
    assert second_user_stat[:browsers] == ''
    assert second_user_stat[:usedIE] == false
    assert second_user_stat[:alwaysUsedChrome] == false
  end

  def test_as_json_returns_json_with_result
    @report.register_user(@user)
    @report.register_session(@session)

    json = @report.as_json
    assert(json.is_a?(String))

    parsed = JSON.parse(json)
    %w[
      totalUsers
      totalSessions
      uniqueBrowsersCount
      allBrowsers
      usersStats
    ].each { |key| assert(parsed.key?(key)) }
  end
end
