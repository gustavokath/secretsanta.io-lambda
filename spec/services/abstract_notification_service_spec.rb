# frozen_string_literal: true

require 'spec_helper'
require 'faker'
require './src/services/abstract_notification_service'

RSpec.describe AbstractNotificationService do
  let(:notification_service) { AbstractNotificationService.new }

  describe '#notify' do
    it 'should raise error' do
      expect { notification_service.notify!(nil, nil, nil) }.to raise_error RuntimeError
    end
  end
end
