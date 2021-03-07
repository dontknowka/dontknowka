RSpec.describe RoundRobin do
  let(:redis) { instance_double('Redis') }
  let(:interactor) { described_class.new(redis: redis) }
  let(:key) { "hw:m1" }
  let(:max) { 4 }

  it 'increment from scratch' do
    expect(redis).to receive(:incr).with(key).and_return(1)
    result = interactor.call(key, max)
    expect(result.value).to eq(1)
  end

  it 'increment' do
    expect(redis).to receive(:incr).with(key).and_return(3)
    result = interactor.call(key, max)
    expect(result.value).to eq(3)
  end

  it 'increment to max' do
    expect(redis).to receive(:incr).with(key).and_return(max)
    result = interactor.call(key, max)
    expect(result.value).to eq(max)
  end

  it 'increment overfill' do
    expect(redis).to receive(:incr).with(key).and_return(max + 1)
    expect(redis).to receive(:set).with(key, 1)
    result = interactor.call(key, max)
    expect(result.value).to eq(1)
  end
end
