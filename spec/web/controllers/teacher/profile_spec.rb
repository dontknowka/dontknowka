RSpec.describe Web::Controllers::Teacher::Profile, type: :action do
  let(:action) { described_class.new(teachers: teachers) }
  let(:params) { { 'rack.session' => session } }

  let(:teachers) { instance_double('TeacherRepository') }

  context 'when user is logged in' do
    let(:session) { { access_token: 'FOO123', role: 'teacher', github_id: github_id, login: 'login', avatar: 'avatar' } }
    let(:github_id) { 123456 }

    it 'is successful' do
      expect(teachers).to receive(:find).with(github_id).and_return('dummy')
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
