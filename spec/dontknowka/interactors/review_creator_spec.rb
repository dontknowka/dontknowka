require 'ostruct'

RSpec.describe ReviewCreator do
  let(:assignments) { instance_double('AssignmentRepository') }
  let(:reviews) { instance_double('ReviewRepository') }
  let(:interactor) { described_class.new(assignments: assignments, reviews: reviews) }

  let(:wrapper) { ->(repo, x) { interactor.call(x[:id], x[:teacher_id], repo, x[:pull], x[:submitted_at], x[:text], x[:url]) } }

  let(:simple_review) { { id: 123456,
                          teacher_id: 9999,
                          pull: 1,
                          submitted_at: 'yesterday',
                          text: 'A little polish is needed',
                          url: 'xxx://yyy' } }
  let(:review_with_strikes) { { id: 654321,
                                teacher_id: 8888,
                                pull: 2,
                                submitted_at: 'yesterday',
                                text: "Need to address those points:\n- [] memory leaks\n- [ ] UB\n-[] iterator usage\n - [] general cleanup\n",
                                url: 'xxx://yyy' } }
  let(:approved_ass) { OpenStruct.new({ id: 111,
                                        status: 'approved' }) }
  let(:failed_ass) { OpenStruct.new({ id: 222,
                                      status: 'failed' }) }
  let(:ready_ass) { OpenStruct.new({ id: 333,
                                     status: 'ready' }) }

  it 'found no assignments' do
    expect(assignments).to receive(:by_repo).with('some_repo').and_return([])
    result = wrapper.call('some_repo', simple_review)
    expect(result.success).to be false
    expect(result.comment).to eq 'No associated assignment'
  end

  it 'found more than one assignment' do
    expect(assignments).to receive(:by_repo).with('some_repo').and_return([1, 2])
    result = wrapper.call('some_repo', simple_review)
    expect(result.success).to be false
    expect(result.comment).to eq 'Several matching assignments'
  end

  it 'assignment is already approved' do
    expect(assignments).to receive(:by_repo).with('some_repo').and_return([approved_ass])
    expect(reviews).not_to receive(:create)
    result = wrapper.call('some_repo', simple_review)
    expect(result.success).to be true
    expect(result.comment).to eq 'Not relevant for this assignment status'
  end

  it 'assignment is failed' do
    expect(assignments).to receive(:by_repo).with('some_repo').and_return([failed_ass])
    expect(reviews).not_to receive(:create)
    result = wrapper.call('some_repo', simple_review)
    expect(result.success).to be true
    expect(result.comment).to eq 'Not relevant for this assignment status'
  end

  it 'review without malus' do
    expect(assignments).to receive(:by_repo).with('some_repo').and_return([ready_ass])
    expect(reviews).to receive(:create).with(hash_including(:number_of_criticism => 0))
    result = wrapper.call('some_repo', simple_review)
    expect(result.success).to be true
    expect(result.comment).to eq ''
  end

  it 'review with malus' do
    expect(assignments).to receive(:by_repo).with('some_repo').and_return([ready_ass])
    expect(reviews).to receive(:create).with(hash_including(:number_of_criticism => 3))
    result = wrapper.call('some_repo', review_with_strikes)
    expect(result.success).to be true
    expect(result.comment).to eq ''
  end
end
