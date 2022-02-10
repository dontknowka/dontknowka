RSpec.describe Admin::Controllers::Teams::Destroy, type: :action do
  let(:action) { described_class.new(team_repo: teams) }
  let(:params) { { 'rack.session' => session, :id => id } }

  let(:teams) { instance_double('TeacherTeamRepository') }
  let(:id) { 111 }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(teams).to receive(:delete).with(id)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/teams'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(teams).not_to receive(:delete)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
