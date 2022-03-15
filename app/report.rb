# frozen_string_literal: true

require 'json'

class Report
  attr_accessor :users_by_id, :sessions_counter, :users_counter, :unique_browsers

  IE_REGEXP = /internet explorer/i
  CHROME_REGEXP = /chrome/i

  def initialize
    @users_by_id = {}
    @sessions_counter = 0
    @users_counter = 0
    @unique_browsers = {}
  end

  def register_user(user)
    return if @users_by_id[user.id]

    @users_by_id[user.id] = user
    @users_counter += 1
  end

  def register_session(session)
    user = @users_by_id[session.user_id]
    raise "there is no user with id #{session.user_id}" if user.nil?

    # store session for user
    user.sessions.push(session)
    # increment sessions count
    @sessions_counter += 1
    # make sure browser is logged as unique
    register_unique_browser(session)
  end

  def as_json
    JSON.fast_generate(result)
  end

  def result
    return @result if defined? @result

    @result = {
      totalUsers: @users_counter,
      totalSessions: @sessions_counter,
      uniqueBrowsersCount: unique_browsers.keys.length,
      allBrowsers: build_all_browsers_string,
      usersStats: build_per_user_stats
    }
  end

  private

  def build_per_user_stats
    @users_by_id
      .map { |(_id, user)| build_stat_for_user(user) }
  end

  def build_stat_for_user(user)
    total_time = 0
    longest_session = 0
    browsers = []
    used_ie = false
    only_chrome = user.sessions.any?
    dates = []

    user.sessions.each do |s|
      # get all the data in one run
      total_time += s.time
      longest_session = s.time unless longest_session > s.time
      browser = s.browser.upcase
      browsers.push(browser)
      dates.push(s.date)
      # boolean flags for browser uses
      used_ie = browser.match?(IE_REGEXP) unless used_ie == true
      next if only_chrome == false

      only_chrome = false unless browser.match?(CHROME_REGEXP)
    end

    dates = dates.sort.reverse.map(&:iso8601)

    {
      alwaysUsedChrome: only_chrome,
      usedIE: used_ie,
      browsers: browsers.join(', '),
      longestSession: longest_session,
      totalTime: total_time,
      firstName: user.first_name,
      lastName: user.last_name,
      id: user.id
    }
  end

  def register_unique_browser(session)
    @unique_browsers[session.browser] ||= true
  end

  def build_all_browsers_string
    @unique_browsers
      .keys
      .map(&:upcase)
      .sort
      .join(', ')
  end
end
