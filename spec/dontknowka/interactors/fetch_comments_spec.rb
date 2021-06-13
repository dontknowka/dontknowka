RSpec.describe FetchComments do
  let(:repo) { 'our-org/some-repo' }
  let(:client) { instance_double('OrgClient') }
  let(:interactor) { described_class.new(client: client) }
  let(:some_comment) { { id: 123456,
                         html_url: 'https://github.com/proba/pull/1#issuecomment-123456',
                         created_at: Time.local(2021, 5, 30, 9, 35, 53),
                         body: 'Interview will be at the end of review',
                         user: { id: 111, login: 'user111' } } }
  let(:interview_comment) { { id: 456789,
                              html_url: 'https://github.com/proba/pull/1#issuecomment-456789',
                              created_at: Time.local(2021, 5, 31, 19, 5, 3),
                              body: 'Interview: [-7]',
                              user: { id: 111, login: 'user111' } } }
  let(:some_review) { { id: 234567,
                        html_url: 'https://github.com/proba/pull/1#pullrequestreview-234567',
                        submitted_at: Time.local(2021, 6, 3, 23, 1, 4),
                        state: 'CHANGES_REQUESTED',
                        user: { id: 222, login: 'user222' } } }
  let(:approve) { { id: 345678,
                    html_url: 'https://github.com/proba/pull/1#pullrequestreview-345678',
                    submitted_at: Time.local(2021, 6, 11, 14, 0, 37),
                    state: 'APPROVED',
                    body: 'Good work!',
                    user: { id: 222, login: 'user222' } } }
  let(:approve_with_interview) { { id: 567890,
                                   html_url: 'https://github.com/proba/pull/1#pullrequestreview-567890',
                                   submitted_at: Time.local(2021, 6, 13, 11, 20, 7),
                                   state: 'APPROVED',
                                   body: 'Interview: [0]',
                                   user: { id: 222, login: 'user222' } } }

  it 'found no pull requests' do
    expect(client).to receive(:pull_requests).with(repo, {state: 'closed'}).and_return([])
    result = interactor.call(repo)
    expect(result.success).to be true
    expect(result.comments).to eq([])
  end

  it 'found no comments no reviews' do
    expect(client).to receive(:pull_requests).with(repo, {state: 'closed'}).and_return([{number: 1}])
    expect(client).to receive(:issue_comments).with(repo, 1).and_return([])
    expect(client).to receive(:pull_request_reviews).with(repo, 1).and_return([])
    result = interactor.call(repo)
    expect(result.success).to be true
    expect(result.comments).to eq([])
  end

  it 'found one irrelevant comment' do
    expect(client).to receive(:pull_requests).with(repo, {state: 'closed'}).and_return([{number: 1}])
    expect(client).to receive(:issue_comments).with(repo, 1).and_return([some_comment])
    expect(client).to receive(:pull_request_reviews).with(repo, 1).and_return([])
    result = interactor.call(repo)
    expect(result.success).to be true
    expect(result.comments).to eq([some_comment])
  end

  it 'found one irrelevant review' do
    expect(client).to receive(:pull_requests).with(repo, {state: 'closed'}).and_return([{number: 1}])
    expect(client).to receive(:issue_comments).with(repo, 1).and_return([])
    expect(client).to receive(:pull_request_reviews).with(repo, 1).and_return([some_review])
    result = interactor.call(repo)
    expect(result.success).to be true
    expect(result.comments).to eq([some_review])
  end

  it 'found two comments and three reviews in two PRs' do
    expect(client).to receive(:pull_requests).with(repo, {state: 'closed'}).and_return([{number: 1}, {number: 2}])
    expect(client).to receive(:issue_comments).with(repo, 1).and_return([some_comment, interview_comment])
    expect(client).to receive(:pull_request_reviews).with(repo, 1).and_return([some_review, approve])
    expect(client).to receive(:issue_comments).with(repo, 2).and_return([])
    expect(client).to receive(:pull_request_reviews).with(repo, 2).and_return([approve_with_interview])
    result = interactor.call(repo)
    expect(result.success).to be true
    expect(result.comments).to eq([some_comment, interview_comment, some_review, approve, approve_with_interview])
  end

  it 'fetch pull requests raise an error' do
    expect(client).to receive(:pull_requests).with(repo, {state: 'closed'}).and_raise(Octokit::NotFound)
    result = interactor.call(repo)
    expect(result.success).to be false
    expect(result.comments).to eq([])
  end

  it 'fetch issue comments raise an error' do
    expect(client).to receive(:pull_requests).with(repo, {state: 'closed'}).and_return([{number: 1}, {number: 2}])
    expect(client).to receive(:issue_comments).with(repo, 1).and_raise(Octokit::NotFound)
    result = interactor.call(repo)
    expect(result.success).to be false
    expect(result.comments).to eq([])
  end

  it 'fetch reviews raise an error' do
    expect(client).to receive(:pull_requests).with(repo, {state: 'closed'}).and_return([{number: 1}])
    expect(client).to receive(:issue_comments).with(repo, 1).and_return([])
    expect(client).to receive(:pull_request_reviews).with(repo, 1).and_raise(Octokit::NotFound)
    result = interactor.call(repo)
    expect(result.success).to be false
    expect(result.comments).to eq([])
  end
end
