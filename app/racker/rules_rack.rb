class RulesRack < Racker
  ROUTES = {
    '/rules' => :rules
  }.freeze

  def rules
    rack_response('rules')
  end
end
