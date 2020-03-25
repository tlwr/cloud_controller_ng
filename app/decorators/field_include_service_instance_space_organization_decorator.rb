module VCAP::CloudController
  class FieldIncludeServiceInstanceSpaceOrganizationDecorator
      def self.match?(fields)
        fields.is_a?(Hash) && fields[:space]&.to_set&.intersect?(self.allowed)
      end

      def self.allowed
         Set['guid', 'relationship.organization']
      end

      def initialize(fields)
        @fields = fields[:space].to_set.intersection(self.class.allowed)
      end

      def decorate(hash, service_instances)
        hash[:included] ||= {}
        spaces = service_instances.map(&:space).uniq

        hash[:included][:spaces] = spaces.sort_by(&:created_at).map do |space|
          temp = {}
          temp[:guid] = space.guid if @fields.include?('guid')
          temp[:relationships] =
            {
              organization: {
                data: {
                  guid: space.organization.guid
                }
              }
            } if @fields.include?('relationship.organization')
          temp
        end

        hash
      end
    end
end
