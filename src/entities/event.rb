# frozen_string_literal: true

# Secret Santa Event
class Event
  attr_accessor :id, :name, :date

  def initialize(id, name, date)
    @id = id
    @name = name
    @date = date
  end
end
