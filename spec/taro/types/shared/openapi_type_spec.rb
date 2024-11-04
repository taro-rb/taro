describe Taro::Types::Shared::OpenAPIType do
  it 'adds an openapi type setter and getter' do
    obj = Object.new.extend(described_class)
    obj.openapi_type = :string
    expect(obj.openapi_type).to eq(:string)
  end

  it 'raises for unsupported openapi types' do
    obj = Object.new.extend(described_class)
    expect { obj.openapi_type = 'string' }.to raise_error(Taro::ArgumentError)
    expect { obj.openapi_type = :boop }.to raise_error(Taro::ArgumentError)
  end
end
