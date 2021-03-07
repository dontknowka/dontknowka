require 'ostruct'

RSpec.describe Web::Controllers::Sessions::New do
  let(:session) { {} }
  let(:params) { { 'rack.session' => session } }
  let(:secret_gen) { instance_double('SecretGen', call: nil) }
  let(:secret) { 'abcdef' }
  let(:client_id) { '12345' }
  let(:action) { described_class.new(secret_gen: secret_gen, client_id: client_id) }
  let(:result) { OpenStruct.new({ :secret => secret }) }

  it 'set auth_secret' do
    expect(secret_gen).to receive(:call).and_return(result)
    response = action.call(params)

    expect(response[0]).to be(200)
    expect(action.exposures[:session][:auth_secret]).to eq(secret)
    expect(action.exposures[:client_id]).to eq(client_id)
    expect(action.exposures[:secret]).to eq(secret)
  end
end
