RSpec.describe Admin::Controllers::Homeworks::Update, type: :action do
  let(:action) { described_class.new(homeworks: homeworks) }
  let(:params) { { 'rack.session' => session, :id => id, :homework => homework } }

  let(:homeworks) { instance_double('HomeworkRepository') }
  let(:id) { 111 }
  let(:homework) { 'dummy' }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(homeworks).to receive(:update).with(id, homework)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/homeworks'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(homeworks).not_to receive(:update)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
