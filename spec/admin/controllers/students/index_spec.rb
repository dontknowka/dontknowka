RSpec.describe Admin::Controllers::Students::Index, type: :action do
  let(:action) { described_class.new(student_repo: students, get_student_score: get_student_score) }
  let(:params) { { 'rack.session' => session } }

  let(:students) { instance_double('StudentRepository') }
  let(:get_student_score) { instance_double('GetStudentScore') }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(students).to receive(:ordered).and_return([])
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(students).not_to receive(:ordered)
      expect(get_student_score).not_to receive(:call)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
