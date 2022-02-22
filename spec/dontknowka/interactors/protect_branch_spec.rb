RSpec.describe ProtectBranch do
  let(:interactor) { described_class.new(client: client) }
  let(:client) { instance_double('OrgClient') }

  let(:repo) { 'some-repo-xyz' }
  let(:team) { 'ta' }

  it 'handles NotFound exception' do
    expect(client).to receive(:protect_branch).and_raise(Octokit::NotFound)
    result = interactor.call(repo, [], [team])
    expect(result.valid).to be false
  end

  it 'returns failure after not finding branch protection' do
    expect(client).to receive(:protect_branch)
    expect(client).to receive(:branch_protection).with(repo, 'master')
    result = interactor.call(repo, [], [team])
    expect(result.valid).to be false
  end

  it 'succeeds' do
    expect(client).to receive(:protect_branch)
    expect(client).to receive(:branch_protection).with(repo, 'master').and_return(1)
    result = interactor.call(repo, [], [team])
    expect(result.valid).to be true
  end
end
