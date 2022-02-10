RSpec.describe Admin::Controllers::Teachers::Destroy, type: :action do
  let(:action) { described_class.new(teacher_repo: teachers) }
  let(:params) { { 'rack.session' => session, :id => id } }

  let(:teachers) { instance_double('TeacherRepository') }
  let(:id) { 111 }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(teachers).to receive(:delete).with(id)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/teachers'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(teachers).not_to receive(:delete)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
