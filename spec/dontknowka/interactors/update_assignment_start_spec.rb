require 'ostruct'

RSpec.describe UpdateAssignmentStart do
  let(:interactor) { described_class.new(assignments: assignments,
                                         team_mappings: mappings,
                                         initialize_repo: initialize_repo) }
  let(:assignments) { instance_double('AssignmentRepository') }
  let(:mappings) { instance_double('TeamMappingRepository') }
  let(:initialize_repo) { instance_double('InitializeRepo') }

  let(:repo) { 'some-repo-xyz' }
  let(:repo_full) { 'org/some-repo-xyz' }
  let(:repo_url) { 'https://github.com/org/some-repo-xyz' }

  let(:ass) { OpenStruct.new(homework_instance_id: 123, id: 987, status: 'open') }
  let(:wrong_status_ass) { OpenStruct.new(homework_instance_id: 123, id: 987, status: 'in_progress') }
  let(:ta) { OpenStruct.new(teacher_team: team) }
  let(:team) { OpenStruct.new(id: 11111, slug: 'ta') }

  let(:comment) { 'some comment' }
  let(:success) { OpenStruct.new(success: true, comment: '') }
  let(:failure) { OpenStruct.new(success: false, comment: comment) }

  it 'fails when there is no assignments' do
    expect(assignments).to receive(:by_repo).and_return([])
    expect(mappings).not_to receive(:by_instance)
    expect(initialize_repo).not_to receive(:call)
    result = interactor.call(repo, repo_full, repo_url)
    expect(result.success).to be false
    expect(result.comment).to eq 'No associated assignment'
  end

  it 'fails when there are several assignments' do
    expect(assignments).to receive(:by_repo).and_return([1, 2, 3])
    expect(mappings).not_to receive(:by_instance)
    expect(initialize_repo).not_to receive(:call)
    result = interactor.call(repo, repo_full, repo_url)
    expect(result.success).to be false
    expect(result.comment).to eq 'Several matching assignments'
  end

  it 'fails when there is no TA team' do
    expect(assignments).to receive(:by_repo).and_return([ass])
    expect(mappings).to receive(:by_instance)
    expect(initialize_repo).not_to receive(:call)
    result = interactor.call(repo, repo_full, repo_url)
    expect(result.success).to be false
    expect(result.comment).to eq "Not found TA mapping for HW instance #{ass.homework_instance_id}"
  end

  it 'fails when assignment is on the wrong stage' do
    expect(assignments).to receive(:by_repo).and_return([wrong_status_ass])
    expect(mappings).not_to receive(:by_instance)
    expect(initialize_repo).not_to receive(:call)
    result = interactor.call(repo, repo_full, repo_url)
    expect(result.success).to be false
    expect(result.comment).to eq "Unexpected assignment stage: #{wrong_status_ass.status}"
  end

  it 'raises an error when repo initialization fails' do
    expect(assignments).to receive(:by_repo).and_return([ass])
    expect(mappings).to receive(:by_instance).and_return(ta)
    expect(initialize_repo).to receive(:call).and_return(failure)
    expect { interactor.call(repo, repo_full, repo_url) }.to raise_error(comment)
  end

  it 'succeeds' do
    expect(assignments).to receive(:by_repo).with(repo).and_return([ass])
    expect(mappings).to receive(:by_instance).with(ass.homework_instance_id).and_return(ta)
    expect(initialize_repo).to receive(:call).with(team.id, team.slug, repo_full).and_return(success)
    expect(assignments).to receive(:update)
    result = interactor.call(repo, repo_full, repo_url)
    expect(result.success).to be true
  end
end
