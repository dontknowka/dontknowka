require 'ostruct'

RSpec.describe Admin::Controllers::Students::View, type: :action do
  let(:action) { described_class.new(students: students, get_student_score: get_student_score) }
  let(:params) { { 'rack.session' => session, :id => id } }

  let(:students) { instance_double('StudentRepository') }
  let(:get_student_score) { instance_double('GetStudentScore') }
  let(:id) { 37 }
  let(:student) { 'dummy' }
  let(:score) { OpenStruct.new({ :total => 100, :bonuses => [], :assignments => [] }) }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(students).to receive(:find).with(id).and_return(student)
      expect(get_student_score).to receive(:call).with(student).and_return(score)
      response = action.call(params)
      expect(response[0]).to eq 200
    end

    it 'student not found' do
      expect(students).to receive(:find).with(id).and_return(nil)
      response = action.call(params)
      expect(response[0]).to eq 404
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(students).not_to receive(:find)
      expect(get_student_score).not_to receive(:call)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
