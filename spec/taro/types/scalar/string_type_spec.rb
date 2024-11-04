describe Taro::Types::Scalar::StringType do
  it 'coerces input' do
    expect(described_class.new('foo').coerce_input).to eq 'foo'
    expect(described_class.new(:foo).coerce_input).to be_nil
  end

  it 'coerces response data' do
    expect(described_class.new('foo').coerce_response).to eq 'foo'
    expect(described_class.new(:foo).coerce_response).to eq 'foo'
    expect(described_class.new(42).coerce_response).to be_nil
  end
end
