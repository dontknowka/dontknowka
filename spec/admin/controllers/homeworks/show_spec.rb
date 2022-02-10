require 'ostruct'

RSpec.describe Admin::Controllers::Homeworks::Show, type: :action do
  let(:action) { described_class.new(homework_repo: homeworks) }
  let(:params) { { 'rack.session' => session, :id => id } }

  let(:homeworks) { instance_double('HomeworkRepository') }
  let(:id) { 111 }
  let(:hw) { OpenStruct.new({ :kind => 'M', :number => 3 }) }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(homeworks).to receive(:find).with(id).and_return(hw)
      expect(homeworks).to receive(:with_assignments).with(id).and_return([])
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(homeworks).not_to receive(:find)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
