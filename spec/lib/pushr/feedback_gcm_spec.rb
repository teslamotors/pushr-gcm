require 'spec_helper'
require 'pushr/feedback_gcm'

describe Pushr::FeedbackGcm do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'create' do
    it 'should create a feedback' do
      feedback = Pushr::FeedbackGcm.new(app: 'app_name', device: 'ab' * 20, follow_up: 'delete', failed_at: Time.now, update_to: nil)
      expect(feedback.app).to eql('app_name')
    end
  end

  describe 'save' do
    let!(:feedback) do
      Pushr::FeedbackGcm.create(app: 'app_name', device: 'ab' * 20, follow_up: 'delete', failed_at: Time.now,
                                update_to: nil)
    end
    it 'should save a feedback' do
      expect(Pushr::Feedback.next.class).to eql(Pushr::FeedbackGcm)
    end
  end
end
