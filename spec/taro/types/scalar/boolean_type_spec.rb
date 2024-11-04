describe Taro::Types::Scalar::BooleanType do
  it 'coerces input' do
    expect(described_class.new(true).coerce_input).to eq true
    expect(described_class.new(false).coerce_input).to eq false
    expect(described_class.new(42).coerce_input).to be_nil
  end

  it 'coerces response data' do
    expect(described_class.new(true).coerce_response).to eq true
    expect(described_class.new(false).coerce_response).to eq false
    expect(described_class.new(42).coerce_response).to be_nil
  end
end
