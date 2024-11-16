describe Taro::Types::EnumType do
  let(:example) do
    stub_const('MyEnum', Class.new(described_class) do
      value 'foo'
      value 'bar'
    end)
  end

  it 'has values' do
    expect(example.values).to eq %w[foo bar]
  end

  it 'deduces openapi_type' do
    expect(example.openapi_type).to eq :string
  end

  it 'coerces input' do
    expect(example.new('foo').coerce_input).to eq 'foo'
    expect { example.new('qux').coerce_input }
      .to raise_error(Taro::InputError, 'String is not valid as MyEnum: must be "foo" or "bar"')
  end

  it 'coerces response data' do
    expect(example.new('foo').coerce_response).to eq 'foo'
    expect { example.new('qux').coerce_response }
      .to raise_error(Taro::ResponseError, 'String is not valid as MyEnum: must be "foo" or "bar"')
  end

  it 'raises for empty enums' do
    empty = Class.new(described_class).new('foo')
    expect { empty.coerce_input }.to raise_error(Taro::Error, /no values/)
    expect { empty.coerce_response }.to raise_error(Taro::Error, /no values/)
  end

  it 'raises for empty enums' do
    enum = Class.new(described_class)
    enum.value 1
    expect { enum.value '2' }.to raise_error(Taro::Error, /mixed type/i)
  end

  it 'inherits values' do
    subclass = Class.new(example)
    subclass.value 'baz'
    expect(example.values).to eq %w[foo bar]
    expect(subclass.values).to eq %w[foo bar baz]
  end
end
