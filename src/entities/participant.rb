# frozen_string_literal: true

# Participant of Secret Santa
class Participant
  attr_accessor :name, :language, :contact_method, :contact

  def initialize(name, language, contact_method, contact)
    @name = name
    @language = language
    @contact_method = contact_method
    @contact = contact
  end

  def sms?
    @contact_method == 'SMS'
  end
end
