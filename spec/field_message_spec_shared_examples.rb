RSpec.shared_examples 'field query parameter' do |field, keys|
  keysList = keys.split(',')

  it "accepts the `fields` parameter with fields[#{field}]=#{keys}" do
    message = described_class.from_params({ 'fields' => { "#{field}": "#{keys}" } })

    expect(message).to be_valid
    expect(message.requested?(:fields)).to be_truthy
    expect(message.fields).to match({ "#{field}": keysList })
  end

  keysList.each do |key|
    it "accepts the `fields` parameter with fields[#{field}]=#{key}" do
      message = described_class.from_params({ 'fields' => { "#{field}": "#{key}" } })

      expect(message).to be_valid
      expect(message.requested?(:fields)).to be_truthy
      expect(message.fields).to match({ "#{field}": [key] })
    end
  end

  it "does not accept fields values that are not #{keys}" do
    message = described_class.from_params({ 'fields' => { "#{field}": "#{keys},foo" } })
    expect(message).not_to be_valid
    quoted_keys = keysList.map {|k| "'#{k}'"}
    expect(message.errors[:fields]).to include("valid values are: #{quoted_keys.join(', ')}")
  end
end