require 'messages/list_message'

module VCAP::CloudController
  class ServiceUsageEventsListMessage < ListMessage
    register_allowed_keys [
      :after_guid,
      :guids,
      :service_instance_types,
      :service_offering_guids,
    ]

    validates_with NoAdditionalParamsValidator
    validates_with DisallowUpdatedAtsParamValidator

    validates :after_guid, array: true, allow_nil: true, length: {
      is: 1,
      wrong_length: 'filter accepts only one guid'
    }

    validates :guids, array: true, allow_nil: true
    validates :service_instance_types, array: true, allow_nil: true
    validates :service_offering_guids, array: true, allow_nil: true

    def valid_order_by_values
      [:created_at]
    end

    def self.from_params(params)
      super(params, %w(after_guid guids service_instance_types service_offering_guids))
    end
  end
end
