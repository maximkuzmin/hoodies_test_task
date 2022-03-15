# frozen_string_literal: true

User = Struct.new(:id, :first_name, :last_name, :age) do
  attr_accessor :sessions

  def initialize(*args)
    super(*args)
    @sessions = []
  end
end
