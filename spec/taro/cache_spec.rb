describe Taro::Cache do
  it 'yields if no cache key is given' do
    expect(Taro::Cache.call(:foo) { :bar }).to eq(:bar)
  end

  it 'supports proc cache keys' do
    expect(DUMMY_CACHE).to receive(:fetch).with(42, expires_in: nil).and_call_original
    expect(Taro::Cache.call(:foo, cache_key: ->(_obj) { 42 }) { :bar }).to eq(:bar)
  end

  it 'supports string cache keys' do
    expect(DUMMY_CACHE).to receive(:fetch).with('hey', expires_in: nil).and_call_original
    expect(Taro::Cache.call(:foo, cache_key: 'hey') { :bar }).to eq(:bar)
  end

  it 'supports hash cache keys' do
    expect(DUMMY_CACHE).to receive(:fetch).with('hey', expires_in: nil).and_call_original
    expect(Taro::Cache.call(:foo, cache_key: { foo: 'hey' }) { :bar }).to eq(:bar)
  end
end
