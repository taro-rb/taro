describe Taro::Types::Field do
  describe '#value_for_response' do
    it 'fetches value from a hash' do
      field = described_class.new(name: :foo, type: S::StringType, null: false)
      expect(field.value_for_response({ foo: 'FOO' })).to eq('FOO')
    end

    it 'fetches value from a hash, with string key' do
      field = described_class.new(name: :foo, type: S::StringType, null: false)
      expect(field.value_for_response({ 'foo' => 'FOO' })).to eq('FOO')
    end

    it 'fetches uses the default if provided' do
      field = described_class.new(name: :foo, type: S::StringType, null: false, default: 'bar')
      expect(field.value_for_response({})).to eq('bar')
    end

    it 'can use :method to access a custom hash key' do
      field = described_class.new(name: :foo, type: S::StringType, null: false, method: :bar)
      expect(field.value_for_response({ bar: 'HI' })).to eq('HI')
    end

    it 'fetches value from an object' do
      field = described_class.new(name: :upcase, type: S::StringType, null: false)
      expect(field.value_for_response('low', object_is_hash: false)).to eq('LOW')
    end

    it 'can use :method to call a custom method' do
      field = described_class.new(name: :foo, type: S::StringType, null: false, method: :upcase)
      expect(field.value_for_response('low', object_is_hash: false)).to eq('LOW')
    end

    it 'fetches value from context if defined directly on it' do
      context = Class.new(T::ObjectType).tap { |o| o.define_method(:upcase) { 'CTX' } }.new(nil)
      field = described_class.new(name: :upcase, type: S::StringType, null: false)
      expect(field.value_for_response('foo', context:, object_is_hash: false)).to eq('CTX')
    end

    it 'uses :method to fetch value from context if defined directly on it' do
      context = Class.new(T::ObjectType).tap { |o| o.define_method(:upcase) { 'CTX' } }.new(nil)
      field = described_class.new(name: :foo, type: S::StringType, null: false, method: :upcase)
      expect(field.value_for_response('foo', context:, object_is_hash: false)).to eq('CTX')
    end

    it 'does not call :method on the context if its an inherited method' do
      context = Class.new(T::ObjectType).new(nil)
      field = described_class.new(name: :foo, type: S::StringType, null: false, method: :inspect)
      expect(field.value_for_response(:ARG, context:, object_is_hash: false)).to eq(':ARG')
    end

    it 'raises for private method usage' do
      foo = 'foo'
      foo.singleton_class.send(:private, :upcase)
      field = described_class.new(name: :upcase, type: S::StringType, null: true)
      expect { field.value_for_response(foo, object_is_hash: false) }.to raise_error(/Private method/i)
    end

    it 'raises for values of the wrong type' do
      field = described_class.new(name: :foo, type: S::StringType, null: false)
      expect do
        field.value_for_response(42, object_is_hash: false)
      end.to raise_error(Taro::ResponseError, /No such method or resolver `:foo`/)
    end
  end
end
