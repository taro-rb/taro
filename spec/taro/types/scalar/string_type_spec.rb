describe Taro::Types::Scalar::StringType do
  it 'coerces input' do
    expect(described_class.new('foo').coerce_input).to eq 'foo'
    expect { described_class.new(:foo).coerce_input }
      .to raise_error(Taro::InputError, /must be a String/)
  end

  it 'coerces response data' do
    expect(described_class.new('foo').coerce_response).to eq 'foo'
    expect(described_class.new(:foo).coerce_response).to eq 'foo'
    expect { described_class.new(42).coerce_response }
      .to raise_error(Taro::ResponseError, /must be a String or Symbol/)
  end
end
