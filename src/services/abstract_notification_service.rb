# frozen_string_literal: true

require_relative './abstract_notification_service'

# Abstract representation of a notification service
class AbstractNotificationService
  def notify!(_event, _giver, _receiver_name)
    raise 'Implement this method in the child class'
  end
end
