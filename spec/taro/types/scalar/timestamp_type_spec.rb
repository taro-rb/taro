describe Taro::Types::Scalar::TimestampType do
  it 'coerces input' do
    expect(described_class.new(1735689600).coerce_input).to eq Time.utc(2025)
    expect { described_class.new('2025').coerce_input }
      .to raise_error(Taro::InputError, /must be an Integer/)
  end

  it 'coerces response data' do
    expect(described_class.new(Time.utc(2025)).coerce_response).to eq 1735689600
    expect(described_class.new(Date.new(2025)).coerce_response).to eq 1735689600
    expect(described_class.new(DateTime.new(2025)).coerce_response).to eq 1735689600
    expect(described_class.new(1735689600).coerce_response).to eq 1735689600
    expect { described_class.new('2025').coerce_response }
      .to raise_error(Taro::ResponseError, /must be a Time, Date, DateTime, or Integer/)
  end
end
