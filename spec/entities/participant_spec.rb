# frozen_string_literal: true

require 'spec_helper'
require 'faker'
require './src/main'
require './src/entities/participant'

RSpec.describe Participant do
  describe '#sms?' do
    context 'contact method is SMS' do
      let(:participant) do
        Participant.new(Faker::Name.name, 'en', 'SMS', Faker::PhoneNumber.cell_phone_in_e164)
      end

      subject { participant.sms? }

      it { is_expected.to be true }
    end

    context 'contact method is Email' do
      let(:participant) do
        Participant.new(Faker::Name.name, 'en', 'EMAIL', Faker::PhoneNumber.cell_phone_in_e164)
      end

      subject { participant.sms? }

      it { is_expected.to be false }
    end
  end
end
