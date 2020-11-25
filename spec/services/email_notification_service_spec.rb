# frozen_string_literal: true

require 'spec_helper'
require 'faker'
require 'mail'
require './src/services/email_notification_service'
require './src/entities/event'
require './src/entities/participant'

RSpec.describe EmailNotificationService do
  let(:notification_service) { EmailNotificationService.new }

  describe '#notify' do
    context 'when it sends notification' do
      let(:event) { Event.new(SecureRandom.uuid, Faker::Restaurant.name, '12/25/2020') }
      let(:receiver) { Faker::Name.name }

      subject { notification_service.notify!(event, giver, receiver) }

      context 'when notification is english' do
        let(:giver) { Participant.new(Faker::Name.name, 'pt-BR', 'EMAIL', 'gugakath@hotmail.com') }

        it 'should call Mail client' do
          allow(Mail).to receive(:deliver).and_return(nil)
          subject
        end
      end
    end
  end
end
