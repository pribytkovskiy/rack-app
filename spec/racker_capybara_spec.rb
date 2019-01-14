require 'spec_helper'

Capybara.app = Rack::Builder.parse_file('config.ru').first

feature Racker do
  let(:name) { 'Dima' }

  describe 'index page' do
    before { visit '/' }

    it 'show index page' do
      expect(page).to have_content('Codebreaker Rack application')
    end

    it 'input name' do
      fill_in('player_name', with: name)
      find('#level').find(:xpath, 'option[3]').select_option
      click_button('Start the game!')
      expect(page).to have_content(name)
    end

    it 'show statistics' do
      click_link('Statistics')
      expect(page).to have_content('Statistics:')
    end

    it 'show rules' do
      click_link('Rules')
      expect(page).to have_content('Welcome to Codebreaker!')
    end
  end

  describe 'game page' do
    before do
      visit '/'
      fill_in('player_name', with: name)
      find('#level').find(:xpath, 'option[3]').select_option
      click_button('Start the game!')
    end

    let(:number) { '1111' }

    it 'attempts -1' do
      fill_in('number', with: number)
      click_button('Submit')
      expect(page).to have_content('9')
    end

    it 'shows hint' do
      click_link('Show hint!')
      expect(page).to have_css('span#hint')
    end

    context 'when game_over' do 
      before do
        10.times do
          fill_in('number', with: number)
          click_button('Submit')
        end
      end

      it 'game_over' do
        expect(page).to have_content('You lose the game!')
      end

      it 'show statistics with game_over' do
        click_link('Statistics')
        expect(page).to have_content('Statistics:')
      end
    end
  end

  describe '404' do
    it '404' do
      visit '/sdhd'
      expect(status_code).to be(200)
    end
  end
end
