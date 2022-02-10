RSpec.describe Admin::Controllers::Instances::Index, type: :action do
  let(:action) { described_class.new(instances: instances, homeworks: homeworks) }
  let(:params) { { 'rack.session' => session } }

  let(:instances) { instance_double('InstanceRepository') }
  let(:homeworks) { instance_double('HomeworkRepository') }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(instances).to receive(:all).and_return([])
      expect(homeworks).to receive(:all).and_return([])
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(instances).not_to receive(:all)
      expect(homeworks).not_to receive(:all)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
