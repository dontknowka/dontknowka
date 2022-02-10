RSpec.describe Admin::Controllers::Bonuses::Destroy, type: :action do
  let(:action) { described_class.new(bonus_repo: bonuses) }
  let(:params) { { 'rack.session' => session, :id => id } }

  let(:bonuses) { instance_double('BonusRepository') }
  let(:id) { 111 }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(bonuses).to receive(:delete).with(id)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/bonuses'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(bonuses).not_to receive(:delete)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
