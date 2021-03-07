require 'ostruct'

RSpec.describe Web::Controllers::Sessions::Auth do
  let(:get_access_token) { instance_double('GetAccessToken', call: nil) }
  let(:action) { described_class.new(get_access_token: get_access_token) }

  context 'with a valid code' do
    let(:code) { '123456789' }
    let(:state) { 'abcdef' }
    let(:session) { { :auth_secret => state } }
    let(:params) { Hash['rack.session' => session, :code => code, :state => state] }
    let(:result) { OpenStruct.new({ :valid => true, :token => 'abc' }) }

    it 'calls get_access_token' do
      expect(get_access_token).to receive(:call).with(code, state).and_return(result)
      action.call(params)
    end

    it 'redirect the user to the root' do
      expect(get_access_token).to receive(:call).and_return(result)
      response = action.call(params)

      expect(response[0]).to eq(302)
      expect(response[1]['Location']).to eq('/')
    end
  end

  context 'with an invalid code' do
    let(:state) { 'abcdef' }
    let(:session) { { :auth_secret => state } }
    let(:params) { Hash['rack.session' => session, :code => 'invalid', :state => state] }
    let(:result) { OpenStruct.new({ :valid => false }) }

    it 'return 403 on an invalid code' do
      expect(get_access_token).to receive(:call).and_return(result)
      response = action.call(params)

      expect(response[0]).to eq(403)
    end
  end
end
