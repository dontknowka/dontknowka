require 'ostruct'

RSpec.describe Web::Controllers::Students::Score, type: :action do
  let(:action) { described_class.new(student_repo: students, get_student_score: get_student_score) }
  let(:params) { { 'rack.session' => session } }

  let(:students) { instance_double('StudentRepository') }
  let(:get_student_score) { instance_double('GetStudentScore') }

  context 'when user is logged in' do
    let(:github_id) { '123456789' }
    let(:session) { { access_token: 'FOO123', github_id: github_id } }
    let(:student) { OpenStruct.new({ login: 'login', avatar: 'avatar' }) }
    let(:score) { OpenStruct.new({ total: 11, bonuses: [], assignments: [] }) }

    it 'is successful' do
      expect(students).to receive(:find).with(github_id).and_return(student)
      expect(get_student_score).to receive(:call).with(student).and_return(score)
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(students).not_to receive(:find)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/login'
    end
  end
end
