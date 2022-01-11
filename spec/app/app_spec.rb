RSpec.describe App do
  include Rack::Test::Methods

  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:game) { Codebreaker::Game.new }
  let(:player_name) { 'test' }
  let(:level) { 'easy' }
  let(:data_path) { './spec/fixtures/' }
  let(:file_name) { 'players.yml' }
  let(:temp_file) { Tempfile.new(file_name, data_path) }
  let(:levels) { Codebreaker::Game::DIFFICULTIES }

  before do
    *_, file_name = temp_file.path.split('/')

    stub_const('Database::DATA_FILE', file_name)
    stub_const('Database::STORAGE_PATH', data_path)
  end

  after do
    temp_file.close
    temp_file.delete
  end

  describe '#index' do
    context 'when form is empty' do
      before do
        get '/'
      end

      it 'return 200' do
        expect(last_response.status).to eq 200
      end

      it 'not save session' do
        expect(last_request.session).to be_empty
      end

      it 'correct displays levels' do
        levels.each_key do |level|
          expect(last_response.body).to include(level.to_s.capitalize)
        end
      end
    end

    context 'when form is filled' do
      before do
        post '/', player_name: player_name, level: level
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to game page' do
        expect(last_response.location).to eq 'game'
      end

      it 'save codebreaker attributes in session' do
        expect(last_request.session[:codebreaker_game]).to be_instance_of(Hash)
      end

      it 'save hints in session' do
        expect(last_request.session[:hints]).to eq []
      end

      it 'save matrix in session' do
        expect(last_request.session[:matrix]).to eq []
      end
    end

    context 'when session is not empty' do
      before do
        env 'rack.session', { codebreaker_game: {} }
        get '/'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to game page' do
        expect(last_response.location).to eq 'game'
      end
    end
  end

  describe '#game' do
    context 'when session is empty' do
      before do
        clear_cookies
        get '/game'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to menu page' do
        expect(last_response.location).to eq '/'
      end
    end

    context 'when correct start' do
      before do
        post '/', player_name: player_name, level: level
        get '/game'
      end

      it 'return 200' do
        expect(last_response.status).to eq 200
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        expect(last_response.body).to include(levels[level.to_sym][:attempts].to_s)
      end

      it 'correct display hints' do
        expect(last_response.body).to include(levels[level.to_sym][:hints].to_s)
      end
    end
  end

  describe '#submit_answer' do
    context 'when correct submit' do
      before do
        post '/', player_name: player_name, level: level
        post '/submit_answer', number: '1111'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to game page' do
        expect(last_response.location).to eq 'game'
      end

      it 'correct save matrix' do
        expect(last_request.session[:matrix].length).to eq 4
      end
    end

    context 'when move to game page' do
      before do
        post '/', player_name: player_name, level: level
        post '/submit_answer', number: '1111'
        get '/game'
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        expect(last_response.body).to include((levels[level.to_sym][:attempts] - 1).to_s)
      end

      it 'correct display hints' do
        expect(last_response.body).to include(levels[level.to_sym][:hints].to_s)
      end
    end

    context 'when session is empty' do
      before do
        clear_cookies
        post '/submit_answer', number: '1111'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to menu page' do
        expect(last_response.location).to eq '/'
      end
    end
  end

  describe '#hint' do
    context 'when game is start' do
      before do
        post '/', player_name: player_name, level: level
      end

      it 'empty' do
        expect(last_request.session[:hints]).to be_empty
      end
    end

    context 'when take hint' do
      before do
        post '/', player_name: player_name, level: level
        post '/hint'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to game page' do
        expect(last_response.location).to eq 'game'
      end

      it 'increased by one' do
        expect(last_request.session[:hints].length).to eq 1
      end
    end

    context 'when move to game page' do
      before do
        post '/', player_name: player_name, level: level
        post '/hint'
        get '/game'
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        expect(last_response.body).to include(levels[level.to_sym][:attempts].to_s)
      end

      it 'correct display hints' do
        expect(last_response.body).to include((levels[level.to_sym][:hints] - 1).to_s)
      end
    end

    context 'when session is empty' do
      before do
        clear_cookies
        get '/hint'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to menu page' do
        expect(last_response.location).to eq '/'
      end
    end
  end

  describe '#win' do
    before do
      post '/', player_name: player_name, level: level
    end

    context 'when user guessed' do
      before do
        post '/submit_answer', number: last_request.session[:codebreaker_game][:@secret_code]
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to win page' do
        expect(last_response.location).to eq 'win'
      end
    end

    context 'when redirect to win page' do
      before do
        post '/submit_answer', number: last_request.session[:codebreaker_game][:@secret_code]
        get '/win'
      end

      it 'clear session' do
        expect(last_request.session).to be_empty
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        included_text = "#{levels[level.to_sym][:attempts] - 1}\n/\n#{levels[level.to_sym][:attempts]}"
        expect(last_response.body).to include(included_text)
      end

      it 'correct display hints' do
        included_text = "#{levels[level.to_sym][:hints]}\n/\n#{levels[level.to_sym][:hints]}"
        expect(last_response.body).to include(included_text)
      end
    end

    context 'when user not guessed' do
      before do
        get '/win'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to win page' do
        expect(last_response.location).to eq '/'
      end
    end

    context 'when session is empty' do
      before do
        clear_cookies
        get '/win'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to menu page' do
        expect(last_response.location).to eq '/'
      end
    end
  end

  describe '#lose' do
    before do
      stub_const('Codebreaker::Game::DIFFICULTIES', { level.to_sym => { attempts: 1, hints: 1 } })
      post '/', player_name: player_name, level: level
      post '/submit_answer', number: secret_code
    end

    let(:secret_code) { last_request.session[:codebreaker_game][:@secret_code] }

    it 'return 302' do
      expect(last_response.status).to eq 302
    end

    it 'redirect to lose page' do
      expect(last_response.location).to eq 'lose'
    end

    context 'when redirect to lose page' do
      before do
        get '/lose'
      end

      it 'clear session' do
        expect(last_request.session).to be_empty
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        included_text = "#{levels[level.to_sym][:attempts] - 1}\n/\n#{levels[level.to_sym][:attempts]}"
        expect(last_response.body).to include(included_text)
      end

      it 'correct display hints' do
        included_text = "#{levels[level.to_sym][:hints]}\n/\n#{levels[level.to_sym][:hints]}"
        expect(last_response.body).to include(included_text)
      end

      it 'correct display secret code' do
        expect(last_response.body).to include(secret_code)
      end
    end

    context 'when session is empty' do
      before do
        clear_cookies
        get '/lose'
      end

      it 'return 302' do
        expect(last_response.status).to eq 302
      end

      it 'redirect to menu page' do
        expect(last_response.location).to eq '/'
      end
    end
  end

  describe '#statistics' do
    context 'when move to statistics page' do
      before do
        get '/statistics'
      end

      it 'return 200' do
        expect(last_response.status).to eq 200
      end
    end

    context 'when user guessed' do
      before do
        post '/', player_name: player_name, level: level
        post '/submit_answer', number: last_request.session[:codebreaker_game][:@secret_code]
        get '/win'
        get '/statistics'
      end

      it 'correct display player name' do
        expect(last_response.body).to include(player_name)
      end

      it 'correct display difficulty' do
        expect(last_response.body).to include(level.capitalize)
      end

      it 'correct display attempts' do
        included_text = "#{levels[level.to_sym][:attempts] - 1}\n/\n#{levels[level.to_sym][:attempts]}"
        expect(last_response.body).to include(included_text)
      end

      it 'correct display hints' do
        included_text = "#{levels[level.to_sym][:hints]}\n/\n#{levels[level.to_sym][:hints]}"
        expect(last_response.body).to include(included_text)
      end
    end
  end

  describe '#rules' do
    before do
      get '/rules'
    end

    it 'return 200' do
      expect(last_response.status).to eq 200
    end
  end

  describe '#unreacheble_path' do
    before do
      get '/unreacheble_path'
    end

    it 'redirect to menu page' do
      expect(last_response.location).to eq '/'
    end
  end
end
