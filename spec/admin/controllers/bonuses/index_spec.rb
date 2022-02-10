RSpec.describe Admin::Controllers::Bonuses::Index, type: :action do
  let(:action) { described_class.new(bonus_repo: bonuses, student_repo: students) }
  let(:params) { { 'rack.session' => session } }

  let(:bonuses) { instance_double('BonusRepository') }
  let(:students) { instance_double('StudentRepository') }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(bonuses).to receive(:with_students).and_return([])
      expect(students).to receive(:all).and_return([])
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(bonuses).not_to receive(:with_students)
      expect(students).not_to receive(:all)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
