RSpec.describe Admin::Controllers::Teachers::Populate, type: :action do
  let(:action) { described_class.new(populate_teachers: populate) }
  let(:params) { { 'rack.session' => session } }

  let(:populate) { instance_double('PopulateTeachers') }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(populate).to receive(:call)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/teachers'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(populate).not_to receive(:call)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
