require 'spec_helper'
require 'actions/service_instance_create_user_provided'
require 'messages/service_instance_create_user_provided_message'

module VCAP
  module CloudController
    RSpec.describe ServiceInstanceCreateUserProvided do
      subject(:action) { described_class.new(event_repository) }

      let(:space) { Space.make }
      let(:message) { ServiceInstanceCreateUserProvidedMessage.new(request) }
      let(:instance) { ServiceInstance.last }
      let(:name) { 'my-service-instance' }

      let(:event_repository) do
        dbl = double(Repositories::ServiceEventRepository::WithUserActor)
        allow(dbl).to receive(:record_user_provided_service_instance_event)
        dbl
      end

      let(:request) do
        {
          type: 'user-provided',
          name: name,
          credentials: {
            foo: 'bar',
            baz: 'qux'
          },
          syslog_drain_url: 'https://drain.com/foo',
          route_service_url: 'https://route.com/bar',
          tags: %w(foo bar baz),
          relationships: {
            space: {
              data: {
                guid: space.guid
              }
            }
          },
          metadata: {
            labels: { potato: 'mashed' },
            annotations: { cheese: 'bono' }
          }
        }
      end

      it 'creates a user-provided service instance' do
        action.create(message)

        expect(instance).to be_a(UserProvidedServiceInstance)
        expect(instance.name).to eq('my-service-instance')
        expect(instance.credentials).to match({ 'foo' => 'bar', 'baz' => 'qux' })
        expect(instance.syslog_drain_url).to eq('https://drain.com/foo')
        expect(instance.route_service_url).to eq('https://route.com/bar')
        expect(instance.tags).to contain_exactly('foo', 'bar', 'baz')
        expect(instance.space).to eq(space)

        expect(instance.labels[0].key_name).to eq('potato')
        expect(instance.labels[0].value).to eq('mashed')
        expect(instance.annotations[0].key_name).to eq('cheese')
        expect(instance.annotations[0].value).to eq('bono')
      end

      it 'creates an audit event' do
        action.create(message)

        request[:credentials] = '[PRIVATE DATA HIDDEN]'

        expect(event_repository).
          to have_received(:record_user_provided_service_instance_event).with(
            :create,
            instance_of(UserProvidedServiceInstance),
            request.with_indifferent_access
          )
      end

      it 'returns the instance' do
        result = action.create(message)
        expect(result).to eq(instance)
      end

      context 'minimum parameters' do
        let(:request) do
          {
            type: 'user-provided',
            name: 'my-service-instance',
            relationships: {
              space: {
                data: {
                  guid: space.guid
                }
              }
            }
          }
        end

        it 'creates a user-provided service instance' do
          action.create(message)

          expect(instance).to be_a(UserProvidedServiceInstance)
          expect(instance.name).to eq('my-service-instance')
          expect(instance.space).to eq(space)
        end
      end

      context 'name is already taken' do
        it 'raises an error' do
          ServiceInstance.make(name: name, space: space)

          expect { action.create(message) }.
            to raise_error(
              ServiceInstanceCreateUserProvided::InvalidUserProvidedServiceInstance,
              "The service instance name is taken: #{name}"
            )
        end
      end

      context 'SQL validation fails' do
        it 'raises an error' do
          errors = Sequel::Model::Errors.new
          errors.add(:blork, 'is busted')
          expect(UserProvidedServiceInstance).to receive(:create).
            and_raise(Sequel::ValidationFailed.new(errors))

          expect { action.create(message) }.
            to raise_error(ServiceInstanceCreateUserProvided::InvalidUserProvidedServiceInstance, 'blork is busted')
        end
      end
    end
  end
end
