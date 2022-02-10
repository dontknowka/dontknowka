require 'ostruct'

RSpec.describe Admin::Controllers::Home::Index, type: :action do
  let(:action) { described_class.new(get_teams: get_teams, homework_instances: instances) }
  let(:params) { { 'rack.session' => session } }

  let(:get_teams) { instance_double('GetTeams') }
  let(:instances) { instance_double('HomeworkInstanceRepository') }
  let(:teams) { OpenStruct.new({ :teams => [] }) }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(instances).to receive(:all).and_return([])
      expect(get_teams).to receive(:call).and_return(teams)
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(instances).not_to receive(:all)
      expect(get_teams).not_to receive(:call)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
