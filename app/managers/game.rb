class GameManager
  attr_reader :codebreaker_game

  WIN_MATRIX = Array.new(4) { '+' }
  PERMITTED_INSTANCE_VARIABLE_FOR_GAME = %i[@secret_code @name @attempts @hints @difficulty @available_hints
                                            @date].freeze

  def initialize(request)
    @request = request
    @codebreaker_game = Codebreaker::Game.new
    configure_game
  end

  def give_hint
    @request.session[:hints] << @codebreaker_game.use_hint
    save_game
  end

  def configure_codebreaker_game
    @codebreaker_game.start
    @codebreaker_game.name = @request.params['player_name']
    @codebreaker_game.difficulty = @request.params['level'].downcase.to_sym
    save_game
  end

  def configure_session_game_process
    matrix = @codebreaker_game.generate_matrix(@request.params['number']).chars
    matrix = ['', '', '', ''].each_with_index.map { |char, index| matrix[index] || char }
    @request.session[:matrix] = matrix
    save_game
  end

  def current_game?
    @request.session.include?('codebreaker_game') && validate_game_attributes?
  end

  def clear_start_session
    @request.session[:matrix] = []
    @request.session[:hints] = []
  end

  def matrix
    @request.session[:matrix]
  end

  def configure_game
    attributes = @request.session[:codebreaker_game]
    attributes&.each { |key, value| @codebreaker_game.instance_variable_set(key, value) }
  end

  def save_game
    attributes = {}
    @codebreaker_game.instance_variables.each do |instance_variable|
      attributes[instance_variable] = @codebreaker_game.instance_variable_get(instance_variable)
    end
    @request.session[:codebreaker_game] = attributes
  end

  def hints
    @request.session[:hints]
  end

  def total_amount(field)
    Codebreaker::Game::DIFFICULTIES.values[@codebreaker_game.difficulty][field]
  end

  def level
    Codebreaker::Game::DIFFICULTIES.keys[@codebreaker_game.difficulty].to_s.capitalize
  end

  def win?
    matrix == WIN_MATRIX
  end

  private

  def validate_game_attributes?
    game_attributes = @request.session[:codebreaker_game]
    return false unless game_attributes.is_a? Hash

    conditions = game_attributes.each_key.map do |instance_variable|
      PERMITTED_INSTANCE_VARIABLE_FOR_GAME.include? instance_variable.to_sym
    end
    conditions.all?
  end
end
