# frozen_string_literal: true

require 'spec_helper'
require 'faker'
require './src/services/abstract_notification_service'
require './src/services/sms_notification_service'
require './src/entities/event'
require './src/entities/participant'

RSpec.describe SMSNotificationService do
  let(:notification_service) { SMSNotificationService.new }

  describe '#notify' do
    context 'when it sends notification' do
      let(:event) { Event.new(SecureRandom.uuid, Faker::Restaurant.name, '12/25/2020') }
      let(:receiver) { Faker::Name.name }

      subject { notification_service.notify!(event, giver, receiver) }

      context 'when notification is english' do
        let(:giver) { Participant.new(Faker::Name.name, 'en', 'SMS', '+5551997245578') }

        it 'should call SNS client' do
          sns_client = Aws::SNS::Client.new(region: 'sa-east-1')
          allow(Aws::SNS::Client).to receive(:new).and_return(sns_client)
          allow(sns_client).to receive(:publish).and_return(nil)
          expect(sns_client).to receive(:publish).with(phone_number: '+5551997245578', message: anything)
          subject
        end
      end
    end
  end
end
