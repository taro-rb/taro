describe Taro::Types::ObjectType do
  before do
    stub_const('ExampleObjectType', Class.new(Taro::Types::ObjectType) do
      field :foo, type: 'String', null: false
      field :bar, type: 'String', null: true
    end)
  end

  it 'coerces input' do
    expect(ExampleObjectType.new({ foo: 'FOO' }).coerce_input).to eq(foo: 'FOO', bar: nil)
  end

  it 'coerces response data' do
    expect(ExampleObjectType.new({ foo: 'FOO' }).coerce_response).to eq(foo: 'FOO', bar: nil)
  end

  it 'coerces objects as response data' do
    obj = Struct.new(:foo, :bar).new('FOO', nil)
    expect(ExampleObjectType.new(obj).coerce_response).to eq(foo: 'FOO', bar: nil)
  end

  it 'works recursively' do
    nested = Class.new(described_class) do
      field :qux, type: 'ExampleObjectType', null: false
    end

    expect(nested.new({ qux: { foo: 'FOO' } }).coerce_input).to eq(qux: { foo: 'FOO', bar: nil })
  end
end
