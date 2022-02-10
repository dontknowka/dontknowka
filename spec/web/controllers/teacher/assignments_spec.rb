require 'ostruct'

RSpec.describe Web::Controllers::Teacher::Assignments, type: :action do
  let(:action) { described_class.new(assignments: assignments,
                                     teachers: teachers,
                                     teacher_mappings: mappings,
                                     fetch_pull_requests: fetch_pull_requests,
                                     check_membership: check_membership) }
  let(:params) { { 'rack.session' => session } }

  let(:assignments) { instance_double('AssignmentRepository') }
  let(:teachers) { instance_double('TeacherRepository') }
  let(:mappings) { instance_double('TeacherMappingRepository') }
  let(:fetch_pull_requests) { instance_double('FetchPullRequests') }
  let(:check_membership) { instance_double('CheckMembership') }

  context 'an existing teacher' do
    let(:github_id) { '123456' }
    let(:session) { { access_token: 'FOO123', role: 'teacher', github_id: github_id, login: 'login', avatar: 'avatar' } }
    let(:teacher) { OpenStruct.new({ id: id }) }
    let(:id) { 123 }
    it 'is successful' do
      expect(teachers).to receive(:find).with(github_id).and_return(teacher)
      expect(mappings).to receive(:by_teacher).with(id).and_return([])
      expect(assignments).to receive(:not_approved).and_return([])
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(teachers).not_to receive(:find)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/login'
    end
  end
end
