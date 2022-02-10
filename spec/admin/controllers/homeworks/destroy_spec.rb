RSpec.describe Admin::Controllers::Homeworks::Destroy, type: :action do
  let(:action) { described_class.new(homeworks: homeworks) }
  let(:params) { { 'rack.session' => session, :id => id } }

  let(:homeworks) { instance_double('HomeworkRepository') }
  let(:id) { 111 }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(homeworks).to receive(:delete).with(id)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/homeworks'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(homeworks).not_to receive(:delete)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
