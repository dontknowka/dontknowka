require 'rest_client'
require 'json'

RSpec.describe GetAccessToken do
  let(:code) { 'foo' }
  let(:client_id) { '12345' }
  let(:client_secret) { 'secret' }
  let(:state) { 'abcde' }
  let(:client) { class_double('RestClient', post: nil) }
  let(:interactor) { described_class.new(client: client, client_id: client_id, client_secret: client_secret) }
  let(:params) { Hash[client_id: client_id, client_secret: client_secret, code: code, state: state] }

  context "good result" do
    let(:token) { 'bar' }
    let(:response) { JSON.generate({ access_token: token }) }

    it "succeeds" do
      expect(client).to receive(:post).with(anything, params, anything).and_return(response)
      result = interactor.call(code, state)
      expect(result.valid).to be true
      expect(result.token).to eq(token)
    end
  end

  context "bad result" do
    it "fails" do
      expect(client).to receive(:post).and_raise(RestClient::ExceptionWithResponse)
      result = interactor.call(code, state)
      expect(result.valid).to be false
    end
  end
end
