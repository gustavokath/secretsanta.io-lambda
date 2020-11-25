# frozen_string_literal: true

require 'json'
require_relative './entities/participant'
require_relative './entities/event'
require_relative './services/sms_notification_service'
require_relative './services/email_notification_service'

# A class to run a Secret Santa draw
class SecretSanta
  # rubocop:disable Lint/UnusedMethodArgument
  def self.run(event:, context:)
    # rubocop:enable Lint/UnusedMethodArgument
    participants = event['participants'].map do |p|
      Participant.new(p['name'], p['language'], p['contact_method'], p['contact'])
    end
    secret_santa = Event.new(event['id'], event['name'], event['date'])

    result = draw(participants)
    notify_all(secret_santa, result) if result
    response_success
  rescue StandardError
    response_fail
  end

  def self.draw(participants)
    size = participants.length
    result = []
    return nil if size < 2

    until size.zero?
      index = rand(size)
      receiver = participants[index]
      participants[index] = participants[size - 1]

      result.push(receiver)
      size -= 1
    end
    result
  end

  def self.notify_all(event, participants)
    count = participants.length
    participants.each_with_index do |p, index|
      receiver = participants[(index + 1) % count]
      notify(event, p, receiver.name)
    end
  end

  def self.notify(event, giver, receiver_name)
    notifier = giver.sms? ? SMSNotificationService.new : EmailNotificationService.new

    notifier.notify!(event, giver, receiver_name)
  end

  def self.response_success
    {
      statusCode: 200,
      headers: response_headers
    }
  end

  def self.response_fail
    {
      statusCode: 400,
      headers: response_headers
    }
  end

  def self.response_headers
    {
      # rubocop:disable Layout/LineLength
      'Access-Control-Allow-Headers' => 'Content-Type,x-requested-with,Access-Control-Allow-Origin,Access-Control-Allow-Headers,Access-Control-Allow-Methods',
      # rubocop:enable Layout/LineLength
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Methods' => 'OPTIONS,POST'
    }
  end
end
