describe Taro::Types::Scalar::IntegerParamType do
  it 'coerces input' do
    expect(described_class.new(1).coerce_input).to eq 1
    expect(described_class.new('1').coerce_input).to eq 1
    expect { described_class.new(1.1).coerce_input }
      .to raise_error(Taro::InputError, /must be an Integer/)
    expect { described_class.new('1a').coerce_input }
      .to raise_error(Taro::InputError, /must be an Integer/)
  end
end
