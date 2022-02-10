RSpec.describe Admin::Controllers::Bonuses::Create, type: :action do
  let(:action) { described_class.new(bonus_repo: bonuses) }
  let(:params) { { 'rack.session' => session, 'bonus' => bonus } }

  let(:bonuses) { instance_double('BonusRepository') }
  let(:bonus) { 'dummy_bonus' }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(bonuses).to receive(:create).with(bonus)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/bonuses'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(bonuses).not_to receive(:create)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
