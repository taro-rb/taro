describe Taro::Types::Shared::OpenAPIName do
  before do
    stub_const('Foo', Module.new)
    stub_const('Foo::BarType', Class.new(T::ObjectType))
  end

  it 'is based on the class name by default' do
    expect(Foo::BarType.openapi_name).to eq('Foo_Bar')
  end

  it 'is based on the class name for enums' do
    stub_const('Foo::QuxType', Class.new(T::EnumType) do
      value 42
    end)
    expect(Foo::QuxType.openapi_name).to eq('Foo_Qux')
  end

  it 'is based on the class name and item_type for lists' do
    expect(S::StringType.array.openapi_name).to eq('string_List')
    expect(Foo::BarType.array.openapi_name).to eq('Foo_Bar_List')
  end

  it 'is based on the class name and item_type for pages' do
    expect(S::StringType.page.openapi_name).to eq('string_Page')
    expect(Foo::BarType.page.openapi_name).to eq('Foo_Bar_Page')
  end

  it 'can be customized' do
    Foo::BarType.openapi_name = 'Bar'
    expect(Foo::BarType.openapi_name).to eq('Bar')
  end

  it 'can be de-customized' do
    Foo::BarType.openapi_name = nil
    expect(Foo::BarType.openapi_name).to eq('Foo_Bar')
  end

  it 'raises when trying to set it to a non-string' do
    expect { Foo::BarType.openapi_name = :boop }.to raise_error(/string/i)
  end

  it 'raises for anonymous type classes that without a custom value' do
    klass = Class.new(T::ObjectType).extend(described_class)
    expect { klass.openapi_name }.to raise_error(Taro::Error, /anonymous/)
  end

  it 'raises for unknown type classes' do
    klass = Class.new.extend(described_class)
    expect { klass.openapi_name }.to raise_error(Taro::Error, /implemented/)
  end
end
