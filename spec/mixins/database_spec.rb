RSpec.describe Database do
  let(:game) { Codebreaker::Game.new }
  let(:dummy_instance) { Class.new { include Database }.new }
  let(:data_path) { './spec/fixtures/' }
  let(:file_name) { 'players.yml' }
  let(:temp_file) { Tempfile.new(file_name, data_path) }

  before do
    *_, file_name = temp_file.path.split('/')

    stub_const('Database::DATA_FILE', file_name)
    stub_const('Database::STORAGE_PATH', data_path)
  end

  context 'when database file is empty' do
    it do
      expect(dummy_instance.load).to eq []
    end
  end

  context 'when save game' do
    it 'increases load size by 1' do
      expect { dummy_instance.save(game) }.to change { dummy_instance.load.length }.by(1)
    end

    it 'write to file Codebreaker::Game instance' do
      dummy_instance.save(game)
      games = YAML.load_file(data_path + file_name)
      games.map { |game| expect(game).to be_a Codebreaker::Game }
    end
  end
end
