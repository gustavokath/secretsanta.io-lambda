# frozen_string_literal: true

require 'spec_helper'
require 'faker'
require 'securerandom'
require './src/main'
require './src/entities/participant'
require './src/entities/event'
require './src/services/sms_notification_service'
require './src/services/email_notification_service'

RSpec.describe SecretSanta do
  let(:secret_santa_event) { Event.new(SecureRandom.uuid, Faker::Restaurant.name, '02/29/2020') }

  describe '.draw' do
    context 'when participants are correct' do
      let(:participants) do
        6.times.collect { Participant.new(Faker::Name.name, 'en', 'SMS', Faker::PhoneNumber.cell_phone_in_e164) }
      end

      subject { SecretSanta.draw(participants) }

      it 'should have each participant once' do
        result = subject
        participants.each do |p|
          expect(result.count(p)).to eq(1)
        end
      end

      it 'should have same size' do
        expect(subject.length).to eq(participants.length)
      end
    end

    context 'when less than 2 participants' do
      let(:participants) { [Participant.new(Faker::Name.name, 'en', 'SMS', Faker::PhoneNumber.cell_phone_in_e164)] }

      subject { SecretSanta.draw(participants) }

      it { is_expected.to be_nil }
    end
  end

  describe '.notify_all' do
    context 'when notify result' do
      let(:participants) do
        6.times.collect { Participant.new(Faker::Name.name, 'en', 'SMS', Faker::PhoneNumber.cell_phone_in_e164) }
      end

      before { allow(SecretSanta).to receive(:notify).and_return(nil) }

      subject { SecretSanta.notify_all(secret_santa_event, participants) }

      it 'notifies each participant' do
        expect(SecretSanta).to receive(:notify).exactly(participants.length)
        subject
      end

      it 'notifies each participant only once' do
        participants.each_with_index do |p, index|
          expect(SecretSanta).to receive(:notify).once.with(secret_santa_event,
                                                            p, participants[(index + 1) % participants.length].name)
        end
        subject
      end
    end
  end

  describe '.notify' do
    context 'when type is SMS' do
      let(:giver) { Participant.new(Faker::Name.name, 'en', 'SMS', Faker::PhoneNumber.cell_phone_in_e164) }
      let(:receiver) { Faker::Name.name }
      let(:sms_notifier) { SMSNotificationService.new }

      before do
        allow(SMSNotificationService).to receive(:new).and_return(sms_notifier)
        allow(sms_notifier).to receive(:notify!).and_return(nil)
      end

      subject { SecretSanta.notify(secret_santa_event, giver, receiver) }

      it 'should call SMS notifier' do
        expect(sms_notifier).to receive(:notify!).with(secret_santa_event, giver, receiver)
        subject
      end
    end

    context 'when type is EMAIL' do
      let(:giver) { Participant.new(Faker::Name.name, 'en', 'EMAIL', Faker::PhoneNumber.cell_phone_in_e164) }
      let(:receiver) { Faker::Name.name }
      let(:email_notifier) { EmailNotificationService.new }

      before do
        allow(EmailNotificationService).to receive(:new).and_return(email_notifier)
        allow(email_notifier).to receive(:notify!).and_return(nil)
      end

      subject { SecretSanta.notify(secret_santa_event, giver, receiver) }

      it 'should call email notifier' do
        expect(email_notifier).to receive(:notify!).with(secret_santa_event, giver, receiver)
        subject
      end
    end
  end

  describe '.response_headers' do
    subject { SecretSanta.response_headers }

    it 'should have valid Allow-Headers' do
      # rubocop:disable Layout/LineLength
      expect(subject['Access-Control-Allow-Headers']).to eq('Content-Type,x-requested-with,Access-Control-Allow-Origin,Access-Control-Allow-Headers,Access-Control-Allow-Methods')
      # rubocop:enable Layout/LineLength
    end

    it 'should have valid Allow-Origin' do
      expect(subject['Access-Control-Allow-Origin']).to eq('*')
    end

    it 'should have valid Allow-Methods' do
      expect(subject['Access-Control-Allow-Methods']).to eq('OPTIONS,POST')
    end
  end

  describe '.response_fail' do
    subject { SecretSanta.response_fail }

    it 'should have status 400' do
      expect(subject[:statusCode]).to eq(400)
    end
  end

  describe '.response_success' do
    subject { SecretSanta.response_success }

    it 'should have status 200' do
      expect(subject[:statusCode]).to eq(200)
    end
  end

  describe '.run' do
    let(:participants) do
      5.times.collect do
        {
          'name' => Faker::Name.name,
          'language' => 'en',
          'contact_method' => 'SMS',
          'contact' => Faker::PhoneNumber.cell_phone_in_e164
        }
      end
    end
    let(:event) { { 'neme' => 'Secret Santa', 'date' => '25/12/2020', 'participants' => participants } }

    describe('when secret santa is successfull') do
      before do
        allow(SecretSanta).to receive(:notify_all).and_return(nil)
      end

      it 'should respond with 200' do
        expect(SecretSanta.run(event: event, context: nil)[:statusCode]).to eq(200)
      end
    end

    describe('when secret santa fails') do
      before do
        allow(SecretSanta).to receive(:notify_all).and_raise('Error')
      end

      it 'should respond with 400' do
        expect(SecretSanta.run(event: event, context: nil)[:statusCode]).to eq(400)
      end
    end
  end
end
