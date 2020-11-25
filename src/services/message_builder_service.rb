# frozen_string_literal: true

# Builds a message to send via notifiction
class MessageBuilderService
  def self.build(message, replace_hash = {})
    replace_hash.each do |key, value|
      message.gsub!("{#{key}}", value)
    end

    message
  end
end
