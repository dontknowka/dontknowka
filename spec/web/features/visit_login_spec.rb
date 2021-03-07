require 'features_helper'

RSpec.describe 'Visit login' do
  it 'is successful' do
    visit '/login'
    expect(page).to have_content('Login')
  end
end
