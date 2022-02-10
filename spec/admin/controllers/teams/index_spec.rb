RSpec.describe Admin::Controllers::Teams::Index, type: :action do
  let(:action) { described_class.new(team_repo: teams) }
  let(:params) { { 'rack.session' => session } }

  let(:teams) { instance_double('TeacherTeamRepository') }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(teams).to receive(:all).and_return([])
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(teams).not_to receive(:all)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
