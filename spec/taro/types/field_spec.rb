describe Taro::Types::Field do
  it 'coerces values' do
    field = described_class.new(name: :foo, type: S::StringType, null: false)
    expect(field.extract_value({ foo: 'FOO' })).to eq('FOO')
    expect(field.extract_value({ foo: 'FOO' }, from_input: false)).to eq('FOO')
  end

  it 'falls back to defaults if given' do
    field = described_class.new(name: :foo, type: S::StringType, null: false, default: 'bar')
    expect(field.extract_value({})).to eq('bar')
  end

  it 'can use :method to access a custom hash key' do
    field = described_class.new(name: :foo, type: S::StringType, null: false, method: :bar)
    expect(field.extract_value({ bar: 'HI' })).to eq('HI')
  end

  it 'can use :method to call a custom method' do
    field = described_class.new(name: :foo, type: S::StringType, null: false, method: :upcase)
    expect(field.extract_value('low', object_is_hash: false)).to eq('LOW')
  end

  it 'calls :method on the context if defined directly on it' do
    context = Class.new(T::ObjectType).tap { |o| o.define_method(:foo) { 'CTX' } }.new(nil)
    field = described_class.new(name: :foo, type: S::StringType, null: false)
    expect(field.extract_value(:ARG, context:, object_is_hash: false)).to eq('CTX')
  end

  it 'does not call :method on the context if its an inherited method' do
    context = Class.new(T::ObjectType).new(nil)
    field = described_class.new(name: :foo, type: S::StringType, null: false, method: :inspect)
    expect(field.extract_value(:ARG, context:, object_is_hash: false)).to eq(':ARG')
  end

  it 'retains nullability constraints with a custom method' do
    field = described_class.new(name: :foo, type: S::StringType, null: false, method: :bar)
    expect do
      field.extract_value({ foo: 'foo' })
    end.to raise_error(Taro::RuntimeError, /not nullable/)
  end

  it 'raises for disallowed null values' do
    field = described_class.new(name: :foo, type: S::StringType, null: false)
    expect do
      field.extract_value({})
    end.to raise_error(Taro::RuntimeError, /not nullable/)
  end

  it 'can allow null values' do
    field = described_class.new(name: :foo, type: S::StringType, null: true)
    expect(field.extract_value({})).to be_nil
  end

  it 'raises for values of the wrong type' do
    field = described_class.new(name: :foo, type: S::StringType, null: false)
    expect do
      field.extract_value(42, object_is_hash: false)
    end.to raise_error(Taro::RuntimeError, /Failed to coerce/)
  end
end
