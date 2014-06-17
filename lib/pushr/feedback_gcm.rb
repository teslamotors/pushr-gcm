module Pushr
  class FeedbackGcm < Pushr::Feedback
    attr_accessor :device, :follow_up, :failed_at, :update_to
    validates :follow_up, inclusion: { in: %w(delete update), message: '%{value} is not a valid follow-up' }

    def to_hash
      { type: 'Pushr::FeedbackGcm', app: app, device: device, follow_up: follow_up, failed_at: failed_at, update_to: update_to }
    end
  end
end
