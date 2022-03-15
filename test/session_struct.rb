# frozen_string_literal: true

require 'date'
require 'minitest/autorun'
require_relative '../app/session'

class SessionTest < Minitest::Test
  def test_struct_work
    session = Session.new(499_998, 8, 'Firefox 33', 49, '2017-06-28')

    assert(session.id == 8)
    assert(session.user_id == 499_998)
    assert(session.browser == 'Firefox 33')
    assert(session.time == 49)
    assert(session.date.is_a?(Date))
    assert(session.date == Date.parse('2017-06-28'))
  end
end
