require 'ostruct'

RSpec.describe GetUserRole do
  let(:org) { 'our-org' }
  let(:ta_team) { 'TA' }
  let(:client) { instance_double('OrgClient') }
  let(:interactor) { described_class.new(client: client, org: org, ta_team: ta_team) }
  let(:ta_team_id) { 98765 }
  let(:teams) { [
    OpenStruct.new({ :name => 'Students', :id => 12345, :slug => 'students' }),
    OpenStruct.new({ :id => ta_team_id, :slug => 'ta', :name => ta_team })
  ] }

  context 'known TA member' do
    let(:user) { 'abcdef' }
    it 'returns teacher role' do
      expect(client).to receive(:org_teams).with(org).and_return(teams)
      expect(client).to receive(:team_member?).with(ta_team_id, user).and_return(true)
      result = interactor.call(user)
      expect(result.role).to eq('teacher')
    end
  end

  context 'not a known TA member' do
    let(:user) { 'qwerty' }
    it 'returns student role' do
      expect(client).to receive(:org_teams).with(org).and_return(teams)
      expect(client).to receive(:team_member?).with(ta_team_id, user).and_return(false)
      result = interactor.call(user)
      expect(result.role).to eq('student')
    end
  end
end
