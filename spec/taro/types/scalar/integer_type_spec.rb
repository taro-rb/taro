describe Taro::Types::Scalar::IntegerType do
  it 'coerces input' do
    expect(described_class.new(1).coerce_input).to eq 1
    expect { described_class.new(1.1).coerce_input }
      .to raise_error(Taro::InputError, /must be an Integer/)
  end

  it 'coerces response data' do
    expect(described_class.new(1).coerce_response).to eq 1
    expect { described_class.new(1.1).coerce_response }
      .to raise_error(Taro::ResponseError, /must be an Integer/)
  end
end
