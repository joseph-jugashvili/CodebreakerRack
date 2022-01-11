class StatisticsRack < Racker
  include Database

  ROUTES = {
    '/statistics' => :statistics
  }.freeze

  def statistics
    rack_response('statistics')
  end
end
