describe Taro::Types::ObjectType do
  let(:example) do
    Class.new(described_class) do
      field(:foo) { [String, null: false] }
      field(:bar) { [String, null: true] }
    end
  end

  it 'coerces input' do
    expect(example.new({ foo: 'FOO' }).coerce_input).to eq(foo: 'FOO', bar: nil)
  end

  it 'coerces response data' do
    expect(example.new({ foo: 'FOO' }).coerce_response).to eq(foo: 'FOO', bar: nil)
  end

  it 'coerces objects as response data' do
    obj = Struct.new(:foo, :bar).new('FOO', nil)
    expect(example.new(obj).coerce_response).to eq(foo: 'FOO', bar: nil)
  end

  it 'works recursively' do
    inner = example
    nested = Class.new(described_class) do
      field(:qux) { [inner, null: false] }
    end

    expect(nested.new({ qux: { foo: 'FOO' } }).coerce_input).to eq(qux: { foo: 'FOO', bar: nil })
  end
end
