# frozen_string_literal: true

class GameRack < Racker
  include Database

  ROUTES = {
    '/' => :index,
    '/submit_answer' => :guess,
    '/game' => :game,
    '/hint' => :hint,
    '/win' => :win,
    '/lose' => :lose
  }.freeze

  def initialize(request)
    super
    @game_manager = GameManager.new(@request)
  end

  def lose
    return redirect('/') unless @game_manager.current_game?

    response = rack_response('lose')
    @request.session.clear
    response
  end

  def win
    return redirect('/') if !@game_manager.current_game? || !@game_manager.win?

    save(@game_manager.codebreaker_game)
    response = rack_response('win')
    @request.session.clear
    response
  end

  def game
    return redirect('/') unless @game_manager.current_game?

    rack_response('game')
  end

  def hint
    return redirect('/') unless @game_manager.current_game?

    @game_manager.give_hint if @game_manager.codebreaker_game.present_hints?

    redirect('game')
  end

  def guess
    return redirect('/') unless @game_manager.current_game?
    return redirect('game') if @request.params['number'].nil?

    @game_manager.configure_session_game_process
    return redirect('lose') unless @game_manager.codebreaker_game.present_attempts?
    return redirect('win') if @game_manager.win?

    redirect('game')
  end

  def index
    return redirect('game') if @game_manager.current_game?
    return rack_response('menu') if @request.params.empty?

    @game_manager.configure_codebreaker_game
    @game_manager.clear_start_session
    redirect('game')
  end
end
