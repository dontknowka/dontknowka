RSpec.describe Admin::Controllers::Sets::Destroy, type: :action do
  let(:action) { described_class.new(sets: sets) }
  let(:params) { { 'rack.session' => session, :id => id } }

  let(:sets) { instance_double('HomeworkSetRepository') }
  let(:id) { 91 }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(sets).to receive(:delete).with(id)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/sets'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(sets).not_to receive(:delete)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
