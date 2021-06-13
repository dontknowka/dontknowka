require 'ostruct'

RSpec.describe CollectInterviews do
  let(:repo_first) { 'our-org/some-repo-first' }
  let(:repo_second) { 'our-org/some-repo-second' }
  let(:assignments) { instance_double('AssignmentRepository') }
  let(:interviews) { instance_double('InterviewRepository') }
  let(:fetch_comments) { instance_double('FetchComments') }
  let(:interactor) { described_class.new(assignments: assignments, fetch_comments: fetch_comments, interviews: interviews) }

  let(:assignment_first) { OpenStruct.new({ id: 1, repo: repo_first }) }
  let(:assignment_second) { OpenStruct.new({ id: 2, repo: repo_second }) }

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
  let(:interview_comment_no_timestamp) { { id: 4567891,
                                           html_url: 'https://github.com/proba/pull/1#issuecomment-4567891',
                                           body: 'Interview: [-7]',
                                           user: { id: 111, login: 'user111' } } }
  let(:interview_comment_no_author) { { id: 4567892,
                                        html_url: 'https://github.com/proba/pull/1#issuecomment-4567892',
                                        created_at: Time.local(2021, 5, 31, 19, 5, 3),
                                        body: 'Interview: [-7]' } }
  let(:interview_comment_invalid_score) { { id: 4567893,
                                            html_url: 'https://github.com/proba/pull/1#issuecomment-4567893',
                                            created_at: Time.local(2021, 5, 31, 19, 5, 3),
                                            body: 'Interview: [fail]',
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

  it 'found no assignments' do
    expect(assignments).to receive(:all_by_instance).with(1).and_return([])
    result = interactor.call(1)
    expect(result.success).to be true
  end

  it 'found no comments' do
    expect(assignments).to receive(:all_by_instance).with(1).and_return([assignment_first])
    expect(fetch_comments).to receive(:call).with(repo_first).and_return(OpenStruct.new({ success: true, comments: [] }))
    result = interactor.call(1)
    expect(result.success).to be true
  end

  it 'found irrelevant comment' do
    expect(assignments).to receive(:all_by_instance).with(1).and_return([assignment_first])
    expect(fetch_comments).to receive(:call).with(repo_first).and_return(OpenStruct.new({ success: true, comments: [some_comment] }))
    result = interactor.call(1)
    expect(result.success).to be true
  end

  it 'found interview comment without a score' do
    expect(assignments).to receive(:all_by_instance).with(1).and_return([assignment_first])
    expect(fetch_comments).to receive(:call).with(repo_first).and_return(OpenStruct.new({ success: true, comments: [interview_comment_invalid_score] }))
    result = interactor.call(1)
    expect(result.success).to be true
  end

  it 'found interview comment without a timestamp' do
    expect(assignments).to receive(:all_by_instance).with(1).and_return([assignment_first])
    expect(fetch_comments).to receive(:call).with(repo_first).and_return(OpenStruct.new({ success: true, comments: [interview_comment_no_timestamp] }))
    result = interactor.call(1)
    expect(result.success).to be false
  end

  it 'found interview comment without an author' do
    expect(assignments).to receive(:all_by_instance).with(1).and_return([assignment_first])
    expect(fetch_comments).to receive(:call).with(repo_first).and_return(OpenStruct.new({ success: true, comments: [interview_comment_no_author] }))
    result = interactor.call(1)
    expect(result.success).to be false
  end

  it 'found interview comment' do
    expect(assignments).to receive(:all_by_instance).with(1).and_return([assignment_first])
    expect(fetch_comments).to receive(:call).with(repo_first).and_return(OpenStruct.new({ success: true, comments: [interview_comment] }))
    expect(interviews).to receive(:find).with(456789).and_return(nil)
    expect(interviews).to receive(:create).with({ id: 456789,
                                                  assignment_id: 1,
                                                  teacher_id: interview_comment[:user][:id],
                                                  submitted_at: interview_comment[:created_at],
                                                  malus: -7,
                                                  url: interview_comment[:html_url] })
    result = interactor.call(1)
    expect(result.success).to be true
  end

  it 'found several comments' do
    expect(assignments).to receive(:all_by_instance).with(1).and_return([assignment_first])
    expect(fetch_comments).to receive(:call).with(repo_first).and_return(OpenStruct.new({ success: true,
                                                                                          comments: [some_comment,
                                                                                                     interview_comment,
                                                                                                     some_review,
                                                                                                     approve,
                                                                                                     approve_with_interview] }))
    expect(interviews).to receive(:find).with(approve_with_interview[:id]).and_return("")
    expect(interviews).to receive(:update).with(approve_with_interview[:id],
                                                { assignment_id: 1,
                                                  teacher_id: approve_with_interview[:user][:id],
                                                  submitted_at: approve_with_interview[:submitted_at],
                                                  malus: 0,
                                                  url: approve_with_interview[:html_url] })
    result = interactor.call(1)
    expect(result.success).to be true
  end

  it 'found several assignments with several comments' do
    expect(assignments).to receive(:all_by_instance).with(1).and_return([assignment_first, assignment_second])
    expect(fetch_comments).to receive(:call).with(repo_first).and_return(OpenStruct.new({ success: true,
                                                                                          comments: [some_comment,
                                                                                                     some_review,
                                                                                                     approve] }))
    expect(fetch_comments).to receive(:call).with(repo_second).and_return(OpenStruct.new({ success: true,
                                                                                           comments: [some_comment,
                                                                                                      interview_comment,
                                                                                                      some_review,
                                                                                                      approve] }))
    expect(interviews).to receive(:find).with(interview_comment[:id]).and_return(nil)
    expect(interviews).to receive(:create).with({ id: interview_comment[:id],
                                                  assignment_id: 2,
                                                  teacher_id: interview_comment[:user][:id],
                                                  submitted_at: interview_comment[:created_at],
                                                  malus: -7,
                                                  url: interview_comment[:html_url] })
    result = interactor.call(1)
    expect(result.success).to be true
  end
end
