RSpec.describe GameManager do
  let(:request) { instance_double('Request') }
  let(:game_manager) { described_class.new(request) }
  let(:player_name) { 'test' }
  let(:level) { 'easy' }
  let(:guess) { '1111' }

  before do
    allow(request).to receive(:session).and_return({})
    allow(request).to receive(:params).and_return({ 'player_name' => player_name, 'level' => level })
  end

  it 'saves request' do
    expect(game_manager.instance_variable_get(:@request)).to eq request
  end

  it 'correct create instance Codebreaker::Game' do
    expect(game_manager.codebreaker_game).to be_instance_of Codebreaker::Game
  end

  describe '#give_hint' do
    before do
      game_manager.configure_codebreaker_game
      game_manager.clear_start_session
    end

    it 'saves hint in session' do
      expect { game_manager.give_hint }.to change { request.session[:hints].size }.by(1)
    end

    context 'when hint is given' do
      before do
        game_manager.give_hint
      end

      it do
        expect(request.session[:hints].first.to_i).to be > 0
      end
    end
  end

  describe '#configure_session_game_process' do
    before do
      allow(request).to receive(:params).and_return({ 'number' => guess })
      game_manager.configure_session_game_process
    end

    it 'saves matrix to session' do
      expect(request.session.keys).to include :matrix
    end

    it 'saves matrix an array' do
      expect(request.session[:matrix]).to be_instance_of Array
    end

    it 'saves matrix an array of length four' do
      expect(request.session[:matrix].size).to eq 4
    end
  end

  describe '#current_game??' do
    it 'returns false' do
      expect(game_manager).not_to be_current_game
    end

    context 'when game is included in session and attributes is false' do
      before do
        allow(request).to receive(:session).and_return({ 'codebreaker_game' => {} })
        allow(game_manager).to receive(:validate_game_attributes?).and_return(false)
      end

      it do
        expect(game_manager).not_to be_current_game
      end
    end

    context 'when game is included in session and attributes is true' do
      before do
        allow(request).to receive(:session).and_return({ 'codebreaker_game' => {} })
        allow(game_manager).to receive(:validate_game_attributes?).and_return(true)
      end

      it do
        expect(game_manager).to be_current_game
      end
    end
  end

  describe '#clear_start_session' do
    before do
      game_manager.clear_start_session
    end

    it ' should save empty matrix array to session' do
      expect(request.session[:matrix]).to eq []
    end

    it 'saves empty array of hints to session' do
      expect(request.session[:hints]).to eq []
    end
  end

  describe '#matrix' do
    let(:matrix) { ['', '', '', ''] }

    before do
      allow(request).to receive(:session).and_return({ matrix: matrix })
    end

    it 'returns matrix' do
      expect(game_manager.matrix).to eq matrix
    end
  end

  describe '#save_game' do
    before do
      game_manager.save_game
    end

    it 'saves attributes codebreaker game instance' do
      expect(request.session[:codebreaker_game].keys).to eq game_manager.codebreaker_game.instance_variables
    end
  end

  describe '#hints' do
    let(:hints) { ['', '', '', ''] }

    before do
      allow(request).to receive(:session).and_return({ hints: hints })
    end

    it 'returns hints' do
      expect(game_manager.hints).to eq hints
    end
  end

  describe '#win?' do
    context 'when user is not win' do
      before do
        allow(game_manager).to receive(:matrix).and_return(['+', '-', '', ''])
      end

      it 'returns false' do
        expect(game_manager).not_to be_win
      end
    end

    context 'when user is win' do
      before do
        allow(game_manager).to receive(:matrix).and_return(GameManager::WIN_MATRIX)
      end

      it 'returns true' do
        expect(game_manager).to be_win
      end
    end
  end
end
