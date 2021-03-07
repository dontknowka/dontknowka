require 'rest_client'
require 'json'

RSpec.describe FetchUser do
  let(:access_token) { 'XYZ' }
  let(:client) { class_double('RestClient', post: nil) }
  let(:interactor) { described_class.new(client: client) }
  let(:headers) { Hash[ Authorization: "Bearer #{access_token}", accept: :json] }

  context "good result" do
    let(:login) { 'LOGIN' }
    let(:email) { 'USER@XYZ.ORG' }
    let(:name) { 'My Name' }
    let(:avatar) { 'https://avatars.github.com/12345' }
    let(:github_id) { 12345 }
    let(:response_data) { { login: login, name: name, id: github_id, avatar_url: avatar, email: nil } }
    let(:emails) { JSON.generate([
      { email: "USER@OTHER_MAIL.COM", verified: true, primary: false, visibility: "public" },
      { email: email, verified: true, primary: true, visibility: "public" },
    ]) }

    it "succeeds with a public email" do
      response_with_email = response_data.clone
      response_with_email[:email] = email
      response = JSON.generate(response_with_email)
      expect(client).to receive(:get).with(anything, headers).and_return(response)
      result = interactor.call(access_token)
      expect(result.valid).to be true
      expect(result.login).to eq(login)
      expect(result.email).to eq(email)
      expect(result.name).to eq(name)
      expect(result.avatar).to eq(avatar)
      expect(result.github_id).to eq(github_id)
    end

    it "succeeds without a public email" do
      response_no_email = JSON.generate(response_data)
      expect(client).to receive(:get).with(anything, headers).and_return(response_no_email, emails)
      result = interactor.call(access_token)
      expect(result.valid).to be true
      expect(result.login).to eq(login)
      expect(result.email).to eq(email)
      expect(result.name).to eq(name)
      expect(result.avatar).to eq(avatar)
      expect(result.github_id).to eq(github_id)
    end
  end

  context "bad result" do
    it "fails" do
      expect(client).to receive(:get).and_raise(RestClient::ExceptionWithResponse)
      result = interactor.call(access_token)
      expect(result.valid).to be false
    end
  end
end
