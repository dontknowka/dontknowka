RSpec.describe Admin::Controllers::Teams::Populate, type: :action do
  let(:action) { described_class.new(populate_teams: populate) }
  let(:params) { { 'rack.session' => session } }

  let(:populate) { instance_double('PopulateTeams') }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(populate).to receive(:call)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/teams'
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
