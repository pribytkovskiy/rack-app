class Racker
  attr_reader :request

  PATCH = {
    '/' => ->(instance) { instance.menu },
    '/start_game' => ->(instance) { instance.start_game },
    '/play_game' => ->(instance) { instance.play_game },
    '/rules' => ->(instance) { instance.view_page(:rules) },
    '/statistics' => ->(instance) { instance.view_page(:statistics) },
    '/hint' => ->(instance) { instance.hint }
  }.freeze

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    PATCH.fetch(request.path).call(self)
  rescue KeyError => e
    redirect_to('404')
  end

  def menu
    redirect_to_game_page_if_game_try

    redirect_to(:menu)
  end

  def start_game
    redirect_to_game_page_if_game_try

    return redirect_to(:menu) if check_level_name?

    game_initialize
    redirect_to(:game)
  end

  def play_game
    return redirect_to(:menu) if request.params['number'].nil?

    game
    redirect_to(check_game)
  end

  def view_page(path)
    redirect_to_game_page_if_game_try

    return redirect_to(:rules) if path == :rules

    return redirect_to(:statistics) if path == :statistics
  end

  def hint
    return redirect_to(:menu) if request.session[:game].nil?

    @request.session[:hint] = request.session[:game].hint
    redirect_to(:game)
  end

  private

  def redirect_to_game_page_if_game_try
    return redirect_to(:game) if request.session[:game]
  end

  def game
    @request.session[:number] = request.params['number']
    @request.session[:guess] = request.session[:game].guess(request.params['number'])
  end

  def check_level_name?
    request.params['name'].nil? && request.params['level'].nil?
  end

  def game_initialize
    @request.session[:name] = request.params['name']
    @request.session[:level] = request.params['level']
    @request.session[:guess] = []
    game_set
  end

  def game_set
    game = Codebreaker::Game.new(request.params['name'])
    game.difficulty(request.params['level'])
    @request.session[:game] = game
  end

  def check_game
    return :lose if request.session[:game].status == :no_attempts

    return :win if request.session[:game].status == :win

    :game
  end

  def save_and_clear
    request.session[:game].save_yml if request.session[:game].status == :win
    request.session.clear
  end

  def redirect_to(path)
    Rack::Response.new(layout { render("/#{path}") })
  end

  def layout
    Haml::Engine.new(File.read(File.expand_path('./views/layout.html.haml', __dir__))).render(binding)
  end

  def render(template)
    path = File.expand_path("../views/#{template}.html.haml", __FILE__)
    Haml::Engine.new(File.read(path)).render(binding)
  end
end
