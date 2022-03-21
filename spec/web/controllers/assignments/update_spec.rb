require 'ostruct'

RSpec.describe Web::Controllers::Assignments::Update, type: :action do
  let(:action) { described_class.new(assignments: assignments, students: students) }
  let(:params) { { 'rack.session' => session, :assignment => { id: id, days: 3, new_late_days: 2, update_prepare: '0', update_approve: '1' } } }

  let(:assignments) { instance_double('AssignmentRepository') }
  let(:students) { instance_double('StudentRepository') }
  let(:id) { 113 }
  let(:sid) { 987 }

  let(:assignment) { OpenStruct.new(id: id, student_id: sid, prepare_deadline: Time.now - 3600, approve_deadline: Time.now + 3600) }
  let(:student) { OpenStruct.new(id: sid, late_days: 5) }

  context 'when user is logged in' do
    let(:session) { { access_token: 'FOO123' } }

    it 'is successful' do
      expect(assignments).to receive(:find).with(id).and_return(assignment)
      expect(students).to receive(:find).with(sid).and_return(student)
      expect(assignments).to receive(:update)
      expect(students).to receive(:update)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/student'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(assignments).not_to receive(:find)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/login'
    end
  end
end
