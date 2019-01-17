require_relative 'autoload'
use Rack::Reloader
use Rack::Static, urls: ['/public', '/node_modules'], root: './'
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: '46235647'

run Racker
