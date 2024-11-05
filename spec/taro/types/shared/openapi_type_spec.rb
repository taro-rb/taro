describe Taro::Types::Shared::OpenAPIType do
  it 'adds an openapi type setter and getter' do
    obj = Object.new.extend(described_class)
    obj.openapi_type = :string
    expect(obj.openapi_type).to eq(:string)
  end

  it 'is inherited' do
    klass = Class.new.extend(described_class)
    klass.openapi_type = :string
    subclass = Class.new(klass)
    expect(subclass.openapi_type).to eq(:string)
  end

  it 'raises when it is missing' do
    obj = Object.new.extend(described_class)
    expect { obj.openapi_type }.to raise_error(Taro::RuntimeError)
  end

  it 'raises when trying to set an unsupported type' do
    obj = Object.new.extend(described_class)
    expect { obj.openapi_type = 'string' }.to raise_error(Taro::ArgumentError)
    expect { obj.openapi_type = :boop }.to raise_error(Taro::ArgumentError)
  end
end
