RSpec.describe StatisticsRack do
  let(:request) { instance_double('Request') }
  let(:statistic_rack) { described_class.new(request) }

  it 'saves request' do
    expect(statistic_rack.instance_variable_get(:@request)).to eq request
  end

  describe '#statistics' do
    before do
      allow(statistic_rack).to receive(:load).and_return([])
    end

    it do
      expect(statistic_rack.statistics).to be_instance_of Rack::Response
    end

    it do
      expect(statistic_rack.statistics.status).to eq 200
    end
  end
end
