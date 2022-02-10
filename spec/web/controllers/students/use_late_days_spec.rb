require 'ostruct'

RSpec.describe Web::Controllers::Students::UseLateDays, type: :action do
  let(:action) { described_class.new(students: students, get_student_score: get_student_score) }
  let(:params) { { 'rack.session' => session, :assignment => assignment } }

  let(:students) { instance_double('StudentRepository') }
  let(:get_student_score) { instance_double('GetStudentScore') }

  context 'when user is logged in' do
    let(:session) { { access_token: 'FOO123', login: 'dummy', github_id: github_id, avatar: 'avatar' } }
    let(:github_id) { '1234567' }
    let(:assignment) { { days: 1, prepare_deadline: Time.new(2041, 1, 2, 10, 45).to_s, approve_deadline: Time.new(2041, 1, 16, 11, 20).to_s } }
    let(:student) { OpenStruct.new({ late_days: 10 }) }
    let(:score) { OpenStruct.new({ total: 83 }) }

    it 'is successful' do
      expect(students).to receive(:find).with(github_id).and_return(student)
      expect(get_student_score).to receive(:call).with(student).and_return(score)
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }
    let(:assignment) { }

    it 'is redirected to login page' do
      expect(students).not_to receive(:find)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/login'
    end
  end
end
