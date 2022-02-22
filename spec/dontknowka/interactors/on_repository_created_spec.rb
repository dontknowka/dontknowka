require 'ostruct'

RSpec.describe OnRepositoryCreated do
  let(:interactor) { described_class.new(update_assignment: update_assignment) }
  let(:update_assignment) { instance_double('UpdateAssignmentStart') }

  let(:payload) { { sender: { type: 'Bot', login: 'classroom' },
                    repository: { name: repo, full_name: repo_full, html_url: repo_url } } }
  let(:repo) { 'some-repo' }
  let(:repo_full) { 'org/some-repo' }
  let(:repo_url) { 'https://github.com/org/some-repo' }

  let(:success) { OpenStruct.new(success: true, comment: '') }
  let(:failure) { OpenStruct.new(success: false, comment: 'Foo') }

  it 'skip uninteresting events' do
    expect(update_assignment).not_to receive(:call)
    result = interactor.call({ sender: { type: 'User' } })
    expect(result.success).to be true
    expect(result.comment).to eq 'Uninteresting'
  end

  it 'fails after 5 attempts' do
    expect(update_assignment).to receive(:call).exactly(5).times.and_raise('foo')
    result = interactor.call(payload)
    expect(result.success).to be false
  end

  it 'succeeds after 2 attempts' do
    expect(update_assignment).to receive(:call).and_raise('foo')
    expect(update_assignment).to receive(:call).with(repo, repo_full, repo_url).and_return(success)
    result = interactor.call(payload)
    expect(result.success).to be true
  end

  it 'fails with unsuccessful update result' do
    expect(update_assignment).to receive(:call).with(repo, repo_full, repo_url).and_return(failure)
    result = interactor.call(payload)
    expect(result.success).to be false
    expect(result.comment).to eq failure.comment
  end
end
