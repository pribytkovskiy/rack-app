class Racker
  attr_reader :request

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response # rubocop:disable Metrics/CyclomaticComplexity
    case request.path
    when '/' then menu
    when '/start_game' then start_game
    when '/play_game' then play_game
    when '/rules' then view_page(:rules)
    when '/statistics' then view_page(:statistics)
    when '/hint' then hint
    else redirect_to('404')
    end
  end

  private

  def menu
    return redirect_to(:game) if request.session[:game]

    redirect_to(:menu)
  end

  def start_game
    return redirect_to(:game) if request.session[:game]

    return redirect_to(:menu) if request.params['name'].nil? && request.params['level'].nil?

    game_initialize
    redirect_to(:game)
  end

  def game_initialize
    @request.session[:name] = request.params['name']
    @request.session[:level] = request.params['level']
    @request.session[:guess] = []
    game = Codebreaker::Game.new(request.params['name'])
    game.difficulty(request.params['level'])
    @request.session[:game] = game
  end

  def play_game
    return redirect_to(:menu) if request.params['number'].nil?

    @request.session[:number] = request.params['number']
    @request.session[:guess] = request.session[:game].guess(request.params['number'])
    redirect_to(check_game)
  end

  def check_game
    return :lose if request.session[:game].status == :no_attempts

    return :win if request.session[:game].status == :win

    :game
  end

  def hint
    return redirect_to(:menu) if request.session[:game].nil?

    @request.session[:hint] = request.session[:game].hint
    redirect_to(:game)
  end

  def save_and_clear
    request.session[:game].save
    request.session.clear
  end

  def view_page(path)
    return redirect_to(:game) if request.session[:game]

    return redirect_to(:rules) if path == :rules

    return redirect_to(:statistics) if path == :statistics
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
