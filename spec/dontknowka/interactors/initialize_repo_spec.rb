require 'ostruct'

RSpec.describe InitializeRepo do
  let(:interactor) { described_class.new(add_team_repo: add_team_repo, protect_branch: protect_branch) }
  let(:add_team_repo) { instance_double('AddTeamRepo') }
  let(:protect_branch) { instance_double('ProtectBranch') }

  let(:team_id) { 1234567 }
  let(:team_slug) { 'ta' }
  let(:repo) { 'some-repo-xyz' }

  let(:success) { OpenStruct.new(valid: true) }
  let(:failure) { OpenStruct.new(valid: false) }

  it 'fails when add team fails' do
    expect(add_team_repo).to receive(:call).and_return(failure)
    expect(protect_branch).not_to receive(:call)
    result = interactor.call(team_id, team_slug, repo)
    expect(result.success).to be false
    expect(result.comment).to eq 'Add team to repo failed'
  end

  it 'fails when protect branch fails' do
    expect(add_team_repo).to receive(:call).and_return(success)
    expect(protect_branch).to receive(:call).and_return(failure)
    result = interactor.call(team_id, team_slug, repo)
    expect(result.success).to be false
    expect(result.comment).to eq 'Protect branch failed'
  end

  it 'succeeds' do
    expect(add_team_repo).to receive(:call).with(team_id, repo).and_return(success)
    expect(protect_branch).to receive(:call).with(repo, [], [team_slug]).and_return(success)
    result = interactor.call(team_id, team_slug, repo)
    expect(result.success).to be true
  end
end
