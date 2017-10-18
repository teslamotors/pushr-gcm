module Pushr
  module Daemon
    module GcmSupport
      class ResponseHandler
        attr_accessor :response, :message
        def initialize(response, message)
          self.response = response
          self.message = message
        end

        def handle
          hsh = MultiJson.load(response.body)
          hsh['results'].each_with_index do |result, index|
            handle_single(result, message.registration_ids[index])
          end
        end

        def handle_single(result, registration_id)
          if result.key?('error')
            if result['error'] == 'NotRegistered' || result['error'] == 'InvalidRegistration'
              Pushr::FeedbackGcm.create(app: message.app, failed_at: Time.now, device: registration_id, follow_up: 'delete')
            end

            if result['error'] == 'Unavailable'
              # TODO: If it is Unavailable, you could retry to send it in another request
              m = message.clone
              m.registration_ids = [registration_id]
              m.save
            end

            # Pushr::Daemon.logger.error("[#{@name}] Error received.")
            # fail Pushr::Daemon::DeliveryError.new(@response.code, nil, msg, 'GCM', false)

          elsif result.key?('registration_id')
            # success, but update device token
            hsh = { app: message.app, failed_at: Time.now, device: registration_id,
                    follow_up: 'update', update_to: result['registration_id'] }
            Pushr::FeedbackGcm.create(hsh)
          end
        end
      end
    end
  end
end
