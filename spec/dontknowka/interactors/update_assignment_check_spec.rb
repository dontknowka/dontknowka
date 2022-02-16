require 'ostruct'

RSpec.describe UpdateAssignmentCheck do
  let(:interactor) { described_class.new(assignments: assignments, check_runs: check_runs) }
  let(:assignments) { instance_double('AssignmentRepository') }
  let(:check_runs) { instance_double('CheckRunRepository') }

  let(:repo) { 'some-repo' }
  let(:pull) { 3 }
  let(:id) { 123 }
  let(:url) { 'some-url' }
  let(:completed_at) { '2022-02-01 10:19:54' }
  let(:ass_id) { 13 }
  let(:ass) { OpenStruct.new(id: ass_id, status: 'in_progress') }
  let(:approved_ass) { OpenStruct.new(id: 13, status: 'approved') }

  it 'fails with no assignments' do
    expect(assignments).to receive(:by_repo).and_return([])
    result = interactor.call(repo, pull, 'success', id, url, completed_at)
    expect(result.success).to be false
    expect(result.comment).to eq 'No associated assignment'
  end

  it 'fails with several matching assignments' do
    expect(assignments).to receive(:by_repo).and_return([1, 2, 3])
    result = interactor.call(repo, pull, 'success', id, url, completed_at)
    expect(result.success).to be false
    expect(result.comment).to eq 'Several matching assignments'
  end

  it 'succeeds with new check run and status transition' do
    expect(assignments).to receive(:by_repo).with(repo).and_return([ass])
    expect(check_runs).to receive(:find).with(id).and_return(nil)
    expect(check_runs).to receive(:create).with(id: id, assignment_id: ass_id, url: url, completed_at: completed_at, pull: pull)
    expect(assignments).to receive(:update).with(ass_id, status: 'ready')
    result = interactor.call(repo, pull, 'success', id, url, completed_at)
    expect(result.success).to be true
  end

  it 'succeeds with new check run and no status transition' do
    expect(assignments).to receive(:by_repo).with(repo).and_return([ass])
    expect(check_runs).to receive(:find).with(id).and_return(nil)
    expect(check_runs).to receive(:create).with(id: id, assignment_id: ass_id, url: url, completed_at: completed_at, pull: pull)
    expect(assignments).not_to receive(:update)
    result = interactor.call(repo, pull, 'failure', id, url, completed_at)
    expect(result.success).to be true
  end

  it 'succeeds with already processed check run' do
    expect(assignments).to receive(:by_repo).with(repo).and_return([ass])
    expect(check_runs).to receive(:find).with(id).and_return('foo')
    expect(check_runs).not_to receive(:create)
    expect(assignments).not_to receive(:update)
    result = interactor.call(repo, pull, 'failure', id, url, completed_at)
    expect(result.success).to be true
    expect(result.comment).to eq 'Already processed that check run'
  end

  it 'succeeds with already approved assignment, no changes' do
    expect(assignments).to receive(:by_repo).with(repo).and_return([approved_ass])
    expect(check_runs).not_to receive(:find)
    expect(check_runs).not_to receive(:create)
    expect(assignments).not_to receive(:update)
    result = interactor.call(repo, pull, 'failure', id, url, completed_at)
    expect(result.success).to be true
  end
end
