# frozen_string_literal: true

require 'date'

class Session < Struct.new(:user_id, :id, :browser, :time, :date)
  def date
    return @date if defined?(@date)

    @date = Date.parse(super())
  end

  def time
    return @time if defined?(@time)
    @time = 
      case super
      when Integer
        super
      when String
        super.to_i
      end
  end
end
