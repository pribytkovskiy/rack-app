require 'spec_helper'

APP = Rack::Builder.parse_file('config.ru').first

module Codebreaker
  RSpec.describe Racker do
    include Rack::Test::Methods

    def app
      APP
    end

    def session
      last_request.env['rack.session']
    end

    let(:player_name) { "Player's name:" }

    describe '404' do
      let(:error_404) { 'Not Found' }

      it '404' do
        get '/sdhdj'
        expect(last_response.body).to include(error_404)
      end
    end

    describe '/ page' do
      before { get '/' }

      it 'successful response' do
        expect(last_response.status).to eq(200)
      end

      it 'shows index page' do
        expect(last_response.body).to include(player_name)
      end

      it 'returns to menu /start_game else not name or level' do
        get '/start_game'
        expect(last_response.body).to include(player_name)
      end

      it 'returns to menu /play_game else not name or level' do
        get '/play_game'
        expect(last_response.body).to include(player_name)
      end
    end

    describe '/statistics page' do
      let(:statistics) { 'Statistics:' }

      before { get '/statistics' }

      it 'successful response' do
        expect(last_response.status).to eq(200)
      end

      it 'entered new name' do
        expect(last_response.body).to include(statistics)
      end
    end

    describe '/rules page' do
      let(:rules) { 'Codebreaker is a logic game' }

      before { get '/rules' }

      it 'successful response' do
        expect(last_response.status).to eq(200)
      end

      it 'entered new name' do
        expect(last_response.body).to include(rules)
      end
    end

    describe 'start_game requests' do
      let(:name) { 'Dima' }
      let(:level) { 'hell' }

      before { get '/start_game', name: name, level: level }

      context 'when render game page' do
        it 'returns 200 response' do
          expect(last_response.status).to eq(200)
        end

        it 'return name' do
          expect(last_response.body).to include(name)
        end

        it 'return level' do
          expect(last_response.body).to include(level)
        end

        it 'include game session' do
          expect(session).to include(:game)
        end
      end

      context 'when render hint page' do
        before { get '/hint' }

        it 'returns 200 response' do
          expect(last_response.status).to eq(200)
        end

        it 'shows hint' do
          expect(session[:hint].first).to match(1..6)
        end
      end

      context 'when render play_game page' do
        let(:number) { '1111' }

        before { get '/play_game', number: number }

        it 'returns 200 response' do
          expect(last_response.status).to eq(200)
        end

        it 'shows number' do
          expect(last_response.body).to include(number)
        end

        it 'include game session' do
          expect(session).to include(:game)
        end
      end
    end

    describe 'hint request' do
      before { get '/hint' }

      it 'successful response' do
        expect(last_response.status).to eq(200)
      end

      it 'redirect_to menu else not game' do
        expect(last_response.body).to include(player_name)
      end
    end
  end
end
