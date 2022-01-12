class App
  include Shortcuts
  MIDDLEWARES = [GameRack, RulesRack, StatisticsRack].freeze

  def self.call(env)
    new(env).response.finish
  end

  def response
    path = @request.path
    MIDDLEWARES.each { |middleware| return middleware.new(@request).response if middleware::ROUTES.keys.include?(path) }
    redirect('/')
  end

  private

  def initialize(env)
    @request = Rack::Request.new(env)
  end
end
