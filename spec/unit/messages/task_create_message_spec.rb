require 'spec_helper'
require 'messages/task_create_message'

module VCAP::CloudController
  RSpec.describe TaskCreateMessage do
    let(:body) do
      {
        'name' => 'mytask',
        'command' => 'rake db:migrate && true',
        'droplet_guid' => Sham.guid,
        'memory_in_mb' => 2048
      }
    end

    describe 'validations' do
      it 'validates that there are not excess fields' do
        body['bogus'] = 'field'
        message = TaskCreateMessage.new(body)

        expect(message).to_not be_valid
        expect(message.errors.full_messages).to include("Unknown field(s): 'bogus'")
      end

      describe 'droplet_guid' do
        it 'can be nil' do
          body.delete 'droplet_guid'

          message = TaskCreateMessage.new(body)

          expect(message).to be_valid
        end

        it 'must be a valid guid' do
          body['droplet_guid'] = 32913

          message = TaskCreateMessage.new(body)

          expect(message).to_not be_valid
        end
      end

      describe 'memory_in_mb' do
        it 'can be nil' do
          body.delete 'memory_in_mb'

          message = TaskCreateMessage.new(body)

          expect(message).to be_valid
        end

        it 'must be numerical' do
          body['memory_in_mb'] = 'trout'

          message = TaskCreateMessage.new(body)

          expect(message).to_not be_valid
          expect(message.errors.full_messages).to include('Memory in mb is not a number')
        end

        it 'may not have a floating point' do
          body['memory_in_mb'] = 4.5

          message = TaskCreateMessage.new(body)

          expect(message).to_not be_valid
          expect(message.errors.full_messages).to include('Memory in mb must be an integer')
        end

        it 'may not be negative' do
          body['memory_in_mb'] = -1

          message = TaskCreateMessage.new(body)

          expect(message).to_not be_valid
          expect(message.errors.full_messages).to include('Memory in mb must be greater than 0')
        end

        it 'may not be zero' do
          body['memory_in_mb'] = 0

          message = TaskCreateMessage.new(body)

          expect(message).to_not be_valid
          expect(message.errors.full_messages).to include('Memory in mb must be greater than 0')
        end
      end

      describe 'disk_in_mb' do
        it 'can be nil' do
          body.delete 'disk_in_mb'

          message = TaskCreateMessage.new(body)

          expect(message).to be_valid
        end

        it 'must be numerical' do
          body['disk_in_mb'] = 'trout'

          message = TaskCreateMessage.new(body)

          expect(message).to_not be_valid
          expect(message.errors.full_messages).to include('Disk in mb is not a number')
        end

        it 'may not have a floating point' do
          body['disk_in_mb'] = 4.5

          message = TaskCreateMessage.new(body)

          expect(message).to_not be_valid
          expect(message.errors.full_messages).to include('Disk in mb must be an integer')
        end

        it 'may not be negative' do
          body['disk_in_mb'] = -1

          message = TaskCreateMessage.new(body)

          expect(message).to_not be_valid
          expect(message.errors.full_messages).to include('Disk in mb must be greater than 0')
        end

        it 'may not be zero' do
          body['disk_in_mb'] = 0

          message = TaskCreateMessage.new(body)

          expect(message).to_not be_valid
          expect(message.errors.full_messages).to include('Disk in mb must be greater than 0')
        end
      end
    end
  end
end