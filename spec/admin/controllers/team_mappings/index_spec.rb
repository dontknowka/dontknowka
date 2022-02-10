RSpec.describe Admin::Controllers::TeamMappings::Index, type: :action do
  let(:action) { described_class.new(mapping_repo: mappings,
                                     team_repo: teams,
                                     instance_repo: instances) }
  let(:params) { { 'rack.session' => session } }

  let(:mappings) { instance_double('TeamMappingRepository') }
  let(:teams) { instance_double('TeacherTeamRepository') }
  let(:instances) { instance_double('HomeworkInstanceRepository') }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(instances).to receive(:all).and_return([])
      expect(teams).to receive(:all).and_return([])
      expect(mappings).to receive(:with_teams).and_return([])
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(mappings).not_to receive(:with_teams)
      expect(teams).not_to receive(:all)
      expect(instances).not_to receive(:all)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
