module Shortcuts
  TEMPLATE_PATH = '../../template/'.freeze
  TEMPLATE_FORMAT = '.html.haml'.freeze
  BASE_TEMPLATE = 'base'.freeze

  def redirect(name)
    Rack::Response.new { |res| res.redirect(name) }
  end

  def rack_response(name)
    Rack::Response.new(render_template(BASE_TEMPLATE) { render_template(name) })
  end

  def render_template(name)
    path = File.expand_path("#{TEMPLATE_PATH}#{name}#{TEMPLATE_FORMAT}", __FILE__)
    Haml::Engine.new(File.read(path)).render(binding)
  end
end
