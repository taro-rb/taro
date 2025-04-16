describe Taro::Types::Shared::OpenAPIFormat do
  before do
    stub_const('Foo', Module.new)
    stub_const('Foo::BarType', Class.new(T::ObjectType))
  end

  it 'returns nil if nothing is set' do
    expect(Foo::BarType.openapi_format).to be_nil
  end

  it 'returns the format if it matches the type string' do
    Foo::BarType.openapi_type = :string
    Foo::BarType.openapi_format = :byte
    expect(Foo::BarType.openapi_format).to eq(:byte)
  end

  it 'returns the format if it matches for type number' do
    Foo::BarType.openapi_type = :number
    Foo::BarType.openapi_format = :float
    expect(Foo::BarType.openapi_format).to eq(:float)
  end

  it 'returns the format if it matches for type integer' do
    Foo::BarType.openapi_type = :integer
    Foo::BarType.openapi_format = :int64
    expect(Foo::BarType.openapi_format).to eq(:int64)
  end

  it 'raises for unknown formats for the specific type' do
    Foo::BarType.openapi_type = :boolean
    Foo::BarType.openapi_format = :int64
    expect { Foo::BarType.openapi_format }.to raise_error(Taro::ArgumentError, /openapi_format :int64 is invalid for openapi_type :boolean/)
  end

  it 'raises for unknown formats' do
    Foo::BarType.openapi_type = :string
    Foo::BarType.openapi_format = :foobar
    expect { Foo::BarType.openapi_format }.to raise_error(Taro::ArgumentError, /openapi_format :foobar is invalid for openapi_type :string/)
  end
end
