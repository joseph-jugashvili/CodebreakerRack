RSpec.describe RulesRack do
  let(:request) { instance_double('Request') }
  let(:rules_rack) { described_class.new(request) }

  it 'saves request' do
    expect(rules_rack.instance_variable_get(:@request)).to eq request
  end

  describe '#rules' do
    it do
      expect(rules_rack.rules).to be_instance_of Rack::Response
    end

    it do
      expect(rules_rack.rules.status).to eq 200
    end
  end
end
