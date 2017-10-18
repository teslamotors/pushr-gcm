module Pushr
  class MessageGcm < Pushr::Message
    POSTFIX = 'gcm'

    attr_accessor :registration_ids, :notification_key, :collapse_key, :delay_while_idle, :time_to_live, :data,
                  :restricted_package_name, :dry_run
    validates :registration_ids, presence: true
    validate :registration_ids_array
    validate :data_size
    validates :delay_while_idle, :dry_run, inclusion: { in: [true, false] }, allow_blank: true
    validates :time_to_live, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2419200 },
                             allow_blank: true

    def to_message
      hsh = {}
      hsh['registration_ids'] = registration_ids
      %w(notification_key collapse_key delay_while_idle time_to_live data restricted_package_name dry_run).each do |variable|
        hsh[variable] = send(variable) if send(variable)
      end
      MultiJson.dump(hsh)
    end

    def to_hash
      hsh = { type: self.class.to_s, app: app, registration_ids: registration_ids, notification_key: notification_key,
              collapse_key: collapse_key, delay_while_idle: delay_while_idle, time_to_live: time_to_live, data: data }
      hsh[Pushr::Core.external_id_tag] = external_id if external_id
      hsh
    end

    private

    def registration_ids_array
      if registration_ids.class == Array
        if registration_ids.size > 1000
          errors.add(:registration_ids, 'is too big (max 1000)')
        elsif registration_ids.size == 0
          errors.add(:registration_ids, 'is too small (min 1)')
        end
      else
        errors.add(:registration_ids, 'is not an array') unless registration_ids.class == Array
      end
    end

    def data_size
      errors.add(:data, 'is more thank 4kb') if data && MultiJson.dump(data).bytes.count > 4096
    end
  end
end
