# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../app/user'

class UserTest < Minitest::Test
  def test_struct_work
    user = User.new(499_999, 'Sammy', 'Ronald', 39)

    assert(user.id == 499_999)
    assert(user.first_name == 'Sammy')
    assert(user.last_name == 'Ronald')
    assert(user.age == 39)
    assert(user.sessions == [])
  end
end
