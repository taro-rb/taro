describe Taro::Types::ObjectTypes::NoContentType do
  it 'renders an empty object' do
    expect(described_class.render).to eq({})
  end

  it 'coerces an empty object as response' do
    expect(described_class.new({}).coerce_response).to eq({})
    expect(described_class.new('foo').coerce_response).to eq({})
  end

  it 'can not coerce input' do
    expect { described_class.new({}).coerce_input }.to raise_error(
      Taro::Error,
      /NoContentType is a ResponseType and cannot be used as input type/
    )
  end
end
