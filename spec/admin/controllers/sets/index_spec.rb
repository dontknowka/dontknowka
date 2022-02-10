RSpec.describe Admin::Controllers::Sets::Index, type: :action do
  let(:action) { described_class.new(sets: sets, instances: instances) }
  let(:params) { { 'rack.session' => session } }

  let(:sets) { instance_double('HomeworkSetRepository') }
  let(:instances) { instance_double('HomeworkInstanceRepository') }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(sets).to receive(:all).and_return([])
      expect(instances).to receive(:all).and_return([])
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(sets).not_to receive(:all)
      expect(instances).not_to receive(:all)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
