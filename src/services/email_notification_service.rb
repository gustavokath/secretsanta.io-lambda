# frozen_string_literal: true

require 'aws-sdk-ses'
require_relative './abstract_notification_service'
require_relative './message_builder_service'
require 'mail'

# Sends Email Notifications
class EmailNotificationService < AbstractNotificationService
  OPTIONS = {
    address: 'smtp.gmail.com',
    port: 587,
    user_name: 'gugakath@gmail.com',
    password: ENV['GMAIL_TOKEN'],
    authentication: 'plain',
    enable_starttls_auto: true
  }.freeze

  def notify!(event, giver, receiver_name)
    language = giver.language
    subject = File.read("./src/resources/notifications/email/subject/#{language}.txt")
    raw_message = File.read("./src/resources/notifications/sms/#{language}.txt")
    message = MessageBuilderService.build(raw_message, {
                                            giver_name: giver.name,
                                            event_name: event.name,
                                            event_date: event.date,
                                            receiver_name: receiver_name
                                          })

    send_gamil_email(subject, message)
  end

  private

  def send_gamil_email(subject, message)
    Mail.defaults do
      delivery_method :smtp, OPTIONS
    end

    Mail.deliver do
      to giver.contact
      from 'gugakath@gmail.com'
      subject subject
      body message
    end
  end
end
