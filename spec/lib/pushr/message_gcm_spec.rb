require 'spec_helper'
require 'pushr/message_gcm'

describe Pushr::MessageGcm do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'next' do
    it 'returns next message' do
      expect(Pushr::Message.next('pushr:app_name:gcm')).to eql(nil)
    end
  end

  describe 'save' do
    let(:message) do
      hsh = { app: 'app_name', registration_ids: ['test'],  collapse_key: 'x',
              delay_while_idle: false, time_to_live: 24 * 60 * 60, data: {}, priority: 'normal' }
      Pushr::MessageGcm.new(hsh)
    end

    it 'should return true' do
      expect(message.save).to eql true
    end
    it 'should save a message' do
      message.save
      expect(Pushr::Message.next('pushr:app_name:gcm')).to be_kind_of(Pushr::MessageGcm)
    end
    it 'should respond to to_message' do
      expect(message.to_message).to be_kind_of(String)
    end

    it 'should contain not more than 1000 registration_ids' do
      hsh = { app: 'app_name', registration_ids: ('a' * 1001).split(//) }
      message = Pushr::MessageGcm.new(hsh)
      expect(message.save).to eql false
    end

    it 'should contain more than 0 registration_ids' do
      hsh = { app: 'app_name', registration_ids: [] }
      message = Pushr::MessageGcm.new(hsh)
      expect(message.save).to eql false
    end

    it 'should contain an array in registration_ids' do
      hsh = { app: 'app_name', registration_ids: nil }
      message = Pushr::MessageGcm.new(hsh)
      expect(message.save).to eql false
    end
  end
end
