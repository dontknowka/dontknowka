RSpec.describe Web::Controllers::Assignments::Update, type: :action do
  let(:action) { described_class.new(assignments: assignments, students: students) }
  let(:params) { { 'rack.session' => session, :assignment => { id: id } } }

  let(:assignments) { instance_double('AssignmentRepository') }
  let(:students) { instance_double('StudentRepository') }
  let(:id) { 113 }

  context 'when user is logged in' do
    let(:session) { { access_token: 'FOO123' } }

    it 'is successful' do
      expect(assignments).to receive(:find).with(id).and_return(nil)
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
