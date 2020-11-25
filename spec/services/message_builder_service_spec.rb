# frozen_string_literal: false

require 'spec_helper'
require 'faker'
require './src/services/message_builder_service'

RSpec.describe MessageBuilderService do
  describe '.build' do
    context 'when nothing to replace' do
      let(:message) { 'Notification Message' }

      subject { MessageBuilderService.build(message) }

      it { is_expected.to eq(message) }
    end

    context 'when replace 1 entry' do
      let(:message) { '{status} Notification Message' }

      subject { MessageBuilderService.build(message, { status: 'Secret Santa' }) }

      it { is_expected.to eq('Secret Santa Notification Message') }
    end

    context 'when replace 2 entry' do
      let(:message) { '{status} Notification Message has count of {count}' }

      subject { MessageBuilderService.build(message, { 'status' => 'Secret Santa', 'count' => 1.to_s }) }

      it { is_expected.to eq('Secret Santa Notification Message has count of 1') }
    end
  end
end
