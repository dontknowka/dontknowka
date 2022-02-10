RSpec.describe Web::Controllers::Teacher::Favorites, type: :action do
  let(:action) { described_class.new(instances: instances,
                                     teacher_mappings: mappings) }
  let(:params) { { 'rack.session' => session } }

  let(:instances) { instance_double('HomeworkInstanceRepository') }
  let(:mappings) { instance_double('TeacherMappingRepository') }

  context 'when user is logged in' do
    let(:session) { { access_token: 'FOO123', role: 'teacher', github_id: github_id, login: 'login', avatar: 'avatar' } }
    let(:github_id) { 123456 }

    it 'is successful' do
      expect(mappings).to receive(:by_teacher).with(github_id).and_return([])
      expect(instances).to receive(:with_homeworks).and_return([])
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(mappings).not_to receive(:by_teacher)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/login'
    end
  end
end
