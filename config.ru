require_relative 'autoloader'

use Rack::Reloader
use Rack::Static, urls: ['/assets'], root: 'view'
use Rack::Session::Cookie, key: 'rack.session', secret: 'secret'

run App
