RSpec.describe Admin::Controllers::TeamMappings::Create, type: :action do
  let(:action) { described_class.new(mapping_repo: mappings) }
  let(:params) { { 'rack.session' => session, :mapping => mapping } }

  let(:mappings) { instance_double('TeamMappingRepository') }
  let(:mapping) { 'dummy' }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(mappings).to receive(:create).with(mapping)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/team_mappings'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(mappings).not_to receive(:create)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
