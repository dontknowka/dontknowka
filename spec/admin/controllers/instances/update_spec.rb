RSpec.describe Admin::Controllers::Instances::Update, type: :action do
  let(:action) { described_class.new(instances: instances) }
  let(:params) { { 'rack.session' => session, :id => id, :instance => instance } }

  let(:instances) { instance_double('InstanceRepository') }
  let(:instance) { 'dummy' }
  let(:id) { 19 }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(instances).to receive(:update).with(id, instance)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/instances'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(instances).not_to receive(:update)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
