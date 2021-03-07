require 'features_helper'

RSpec.describe 'Visit home' do
  context 'when user is not logged in' do
    it 'redirect to login page' do
      visit '/'
      expect(page).to have_content('Login with GitHub')
    end
  end
end
