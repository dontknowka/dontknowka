RSpec.describe Events::Controllers::Home::New, type: :action do
  let(:action) { described_class.new }
  let(:params) { { 'HTTP_X_HUB_SIGNATURE_256' => 'foo', 'rack.input' => StringIO.new("dummy event") } }

  it 'signature verification failed' do
    response = action.call(params)
    expect(response[0]).to eq 500
  end
end
