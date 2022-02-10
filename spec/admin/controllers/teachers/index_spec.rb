RSpec.describe Admin::Controllers::Teachers::Index, type: :action do
  let(:action) { described_class.new(teacher_repo: teachers) }
  let(:params) { { 'rack.session' => session } }

  let(:teachers) { instance_double('TeacherRepository') }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(teachers).to receive(:teachers_with_teams).and_return([])
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(teachers).not_to receive(:teachers_with_teams)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
