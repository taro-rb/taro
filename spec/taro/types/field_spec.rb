describe Taro::Types::Field do
  describe '#initialize' do
    it 'defaults to null: false' do
      expect(described_class.new(name: :bar, type: S::StringType).null).to eq(false)
    end

    it 'can default to null: true via the config', config: { default_value_for_null: true } do
      expect(described_class.new(name: :bar, type: S::StringType).null).to eq(true)
    end

    it 'defaults to required: true' do
      expect(described_class.new(name: :bar, type: S::StringType).required).to eq(true)
    end

    it 'can default to required: false via the config', config: { default_value_for_required: false } do
      expect(described_class.new(name: :bar, type: S::StringType).required).to eq(false)
    end

    it 'defaults required to false if default is provided' do
      expect(described_class.new(name: :bar, type: S::StringType, default: 'x').required).to eq(false)
    end
  end

  describe '#value_for_response' do
    it 'fetches value from a hash' do
      field = described_class.new(name: :foo, type: S::StringType)
      expect(field.value_for_response({ foo: 'FOO' })).to eq('FOO')
    end

    it 'fetches value from a hash, with string key' do
      field = described_class.new(name: :foo, type: S::StringType)
      expect(field.value_for_response({ 'foo' => 'FOO' })).to eq('FOO')
    end

    it 'fetches uses the default if provided' do
      field = described_class.new(name: :foo, type: S::StringType, default: 'bar')
      expect(field.value_for_response({})).to eq('bar')
    end

    it 'can use :method to access a custom hash key' do
      field = described_class.new(name: :foo, type: S::StringType, method: :bar)
      expect(field.value_for_response({ bar: 'HI' })).to eq('HI')
    end

    it 'fetches value from an object' do
      field = described_class.new(name: :upcase, type: S::StringType)
      expect(field.value_for_response('low', object_is_hash: false)).to eq('LOW')
    end

    it 'can use :method to call a custom method' do
      field = described_class.new(name: :foo, type: S::StringType, method: :upcase)
      expect(field.value_for_response('low', object_is_hash: false)).to eq('LOW')
    end

    it 'fetches value from context if defined directly on it' do
      context = Class.new(T::ObjectType).tap { |o| o.define_method(:upcase) { 'CTX' } }.new(nil)
      field = described_class.new(name: :upcase, type: S::StringType)
      expect(field.value_for_response('foo', context:, object_is_hash: false)).to eq('CTX')
    end

    it 'fetches value from context for hashes' do
      context = Class.new(T::ObjectType).tap { |o| o.define_method(:v) { object[:k] } }.new({ k: 'V' })
      field = described_class.new(name: :v, type: S::StringType)
      expect(field.value_for_response('foo', context:, object_is_hash: false)).to eq('V')
    end

    it 'uses :method to fetch value from context if defined directly on it' do
      context = Class.new(T::ObjectType).tap { |o| o.define_method(:upcase) { 'CTX' } }.new(nil)
      field = described_class.new(name: :foo, type: S::StringType, method: :upcase)
      expect(field.value_for_response('foo', context:, object_is_hash: false)).to eq('CTX')
    end

    it 'does not call :method on the context if its an inherited method' do
      context = Class.new(T::ObjectType).new(nil)
      field = described_class.new(name: :foo, type: S::StringType, method: :inspect)
      expect(field.value_for_response(:ARG, context:, object_is_hash: false)).to eq(':ARG')
    end

    it 'raises for private method usage' do
      foo = 'foo'
      foo.singleton_class.send(:private, :upcase)
      field = described_class.new(name: :upcase, type: S::StringType)
      expect { field.value_for_response(foo, object_is_hash: false) }.to raise_error(/Private method/i)
    end

    it 'raises for values of the wrong type' do
      field = described_class.new(name: :foo, type: S::StringType)
      expect do
        field.value_for_response(42, object_is_hash: false)
      end.to raise_error(Taro::ResponseError, /No such method or resolver `:foo`/)
    end
  end

  describe '#value_for_input' do
    it 'returns coerced value when key is present' do
      field = described_class.new(name: :foo, type: S::StringType)
      expect(field.value_for_input({ foo: 'bar' })).to eq('bar')
    end

    it 'raises when required field key is missing' do
      field = described_class.new(name: :foo, type: S::StringType)
      expect { field.value_for_input({}) }.to raise_error(Taro::InputError, /required/)
    end

    it 'raises when required field and object is nil' do
      field = described_class.new(name: :foo, type: S::StringType)
      expect { field.value_for_input(nil) }.to raise_error(Taro::InputError, /required/)
    end

    it 'returns Taro::None when optional field key is missing' do
      field = described_class.new(name: :foo, type: S::StringType, required: false)
      expect(field.value_for_input({})).to equal(Taro::None)
    end

    it 'returns default when optional field key is missing and default is set' do
      field = described_class.new(name: :foo, type: S::StringType, required: false, default: 'fallback')
      expect(field.value_for_input({})).to eq('fallback')
    end

    it 'allows required: true with null: true (required but nullable)' do
      field = described_class.new(name: :foo, type: S::StringType, null: true, required: true)
      expect { field.value_for_input({}) }.to raise_error(Taro::InputError, /required/)
      expect(field.value_for_input({ foo: nil })).to be_nil
    end

    it 'allows required: false with null: false (optional but non-nullable)' do
      field = described_class.new(name: :foo, type: S::StringType, required: false)
      expect(field.value_for_input({})).to equal(Taro::None)
      expect { field.value_for_input({ foo: nil }) }.to raise_error(Taro::InputError)
    end
  end
end
