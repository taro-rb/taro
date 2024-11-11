describe Taro::Types::Scalar::UUIDv4Type do
  let(:uuid) { "1731ff84-6a19-4bf6-ba40-054432dd5f77" }

  it 'coerces input' do
    expect(described_class.new(uuid).coerce_input).to eq uuid
    expect(described_class.new(uuid.tr('-', '')).coerce_input).to eq uuid.tr('-', '')
    expect { described_class.new(uuid[1..]).coerce_input }
      .to raise_error(Taro::InputError, /must be a UUID v4 string/)
  end

  it 'coerces response data' do
    expect(described_class.new(uuid).coerce_response).to eq uuid
    expect(described_class.new(uuid.tr('-', '')).coerce_response).to eq uuid.tr('-', '')
    expect { described_class.new(uuid[1..]).coerce_response }
      .to raise_error(Taro::ResponseError, /must be a UUID v4 string/)
  end
end
