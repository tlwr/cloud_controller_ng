require 'presenters/v3/base_presenter'
require 'presenters/mixins/metadata_presentation_helpers'

module VCAP::CloudController::Presenters::V3
  class SpacePresenter < BasePresenter
    include VCAP::CloudController::Presenters::Mixins::MetadataPresentationHelpers

    class << self
      # :labels and :annotations come from MetadataPresentationHelpers
      def associated_resources
        super << :organization
      end
    end

    def to_hash
      hash = {
        guid: space.guid,
        created_at: space.created_at,
        updated_at: space.updated_at,
        name: space.name,
        relationships: {
          organization: {
            data: {
              guid: space.organization_guid
            }
          },
          quota: {
            data: space.space_quota_definition ? { guid: space.space_quota_definition_guid } : nil
          }
        },
        links: build_links,
        metadata: {
          labels: hashified_labels(space.labels),
          annotations: hashified_annotations(space.annotations),
        }
      }

      @decorators.reduce(hash) { |memo, d| d.decorate(memo, [space]) }
    end

    private

    def space
      @resource
    end

    def build_links
      url_builder = VCAP::CloudController::Presenters::ApiUrlBuilder.new

      links = {
        self: {
          href: url_builder.build_url(path: "/v3/spaces/#{space.guid}")
        },
        organization: {
          href: url_builder.build_url(path: "/v3/organizations/#{space.organization_guid}")
        },
      }

      links[:quota] = { href: url_builder.build_url(path: "/v3/space_quotas/#{space.space_quota_definition_guid}") } if space.space_quota_definition

      links
    end
  end
end
