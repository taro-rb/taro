describe Taro::Types::Scalar::DateType do
  it 'coerces input' do
    expect(described_class.new(1735686000).coerce_input).to eq Date.new(2025)
    expect(described_class.new(1735686001).coerce_input).to eq Date.new(2025)
    expect(described_class.new('2025').coerce_input).to be_nil
  end

  it 'coerces response data' do
    expect(described_class.new(Time.utc(2025)).coerce_response).to eq 1735686000
    expect(described_class.new(Date.new(2025)).coerce_response).to eq 1735686000
    expect(described_class.new(DateTime.new(2025)).coerce_response).to eq 1735686000
    expect(described_class.new(1735686000).coerce_response).to eq 1735686000
    expect(described_class.new(1735686001).coerce_response).to eq 1735686000
    expect(described_class.new('2025').coerce_response).to be_nil
  end
end
