module VCAP
  module CloudController
    class AppFactory
      def self.make(*args)
        parent_app_attributes = args.extract_options!.symbolize_keys
        attributes = parent_app_attributes.slice!(:name, :space, :environment_json, :stack)
        package_attributes = attributes
        attributes = package_attributes.slice!(:docker_image)

        defaults = {
            droplet_hash: Sham.guid,
            metadata: {},
        }
        attributes = defaults.merge(attributes)

        if parent_app_attributes.any?
          buildpack_keys = {}

          if parent_app_attributes.key?(:environment_json)
            parent_app_attributes[:environment_variables] = parent_app_attributes[:environment_json]
            parent_app_attributes.delete(:environment_json)
          end
          if parent_app_attributes.key?(:stack)
            buildpack_keys[:stack] = parent_app_attributes[:stack].name
            parent_app_attributes.delete(:stack)
          end

          attributes[:app] = VCAP::CloudController::AppModel.make(parent_app_attributes)

          attributes[:app].lifecycle_data.update(buildpack_keys) if buildpack_keys.any?
        end

        args << attributes

        app = VCAP::CloudController::App.make(*args)

        if package_attributes.empty?
          VCAP::CloudController::PackageModel.make(app: app.app, state: PackageModel::READY_STATE, package_hash: Sham.guid)
        else
          VCAP::CloudController::PackageModel.make(:docker, app: app.app, docker_image: package_attributes[:docker_image])
        end

        app.add_new_droplet(app.droplet_hash) if app.droplet_hash
        app.reload
      end
    end
  end
end
