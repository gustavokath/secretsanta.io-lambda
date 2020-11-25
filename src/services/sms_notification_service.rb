# frozen_string_literal: true

require 'aws-sdk-sns'
require_relative './abstract_notification_service'
require_relative './message_builder_service'

# Sends SMS notifications
class SMSNotificationService < AbstractNotificationService
  def notify!(event, giver, receiver_name)
    language = giver.language
    raw_message = File.read("./src/resources/notifications/sms/#{language}.txt")
    message = MessageBuilderService.build(raw_message, {
                                            giver_name: giver.name,
                                            event_name: event.name,
                                            event_date: event.date,
                                            receiver_name: receiver_name
                                          })

    sns_client = Aws::SNS::Client.new
    sns_client.publish(phone_number: giver.contact, message: message)
  end
end
