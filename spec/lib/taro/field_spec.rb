describe Taro::Field do
  describe '#extract_value' do
    it 'fetches value from a hash' do
      field = described_class.new(name: :foo, type: S::StringType, null: false)
      expect(field.extract_value({ foo: 'FOO' })).to eq('FOO')
    end

    it 'fetches value from a hash, with string key' do
      field = described_class.new(name: :foo, type: S::StringType, null: false)
      expect(field.extract_value({ 'foo' => 'FOO' })).to eq('FOO')
    end

    it 'fetches uses the default if provided' do
      field = described_class.new(name: :foo, type: S::StringType, null: false, default: 'bar')
      expect(field.extract_value({})).to eq('bar')
    end

    it 'can use :method to access a custom hash key' do
      field = described_class.new(name: :foo, type: S::StringType, null: false, method: :bar)
      expect(field.extract_value({ bar: 'HI' })).to eq('HI')
    end

    it 'fetches value from an object' do
      field = described_class.new(name: :upcase, type: S::StringType, null: false)
      expect(field.extract_value('low', object_is_hash: false)).to eq('LOW')
    end

    it 'can use :method to call a custom method' do
      field = described_class.new(name: :foo, type: S::StringType, null: false, method: :upcase)
      expect(field.extract_value('low', object_is_hash: false)).to eq('LOW')
    end

    it 'fetches value from context if defined directly on it' do
      context = Class.new(T::ObjectType).tap { |o| o.define_method(:upcase) { 'CTX' } }.new(nil)
      field = described_class.new(name: :upcase, type: S::StringType, null: false)
      expect(field.extract_value('foo', context:, object_is_hash: false)).to eq('CTX')
    end

    it 'uses :method to fetch value from context if defined directly on it' do
      context = Class.new(T::ObjectType).tap { |o| o.define_method(:upcase) { 'CTX' } }.new(nil)
      field = described_class.new(name: :foo, type: S::StringType, null: false, method: :upcase)
      expect(field.extract_value('foo', context:, object_is_hash: false)).to eq('CTX')
    end

    it 'does not call :method on the context if its an inherited method' do
      context = Class.new(T::ObjectType).new(nil)
      field = described_class.new(name: :foo, type: S::StringType, null: false, method: :inspect)
      expect(field.extract_value(:ARG, context:, object_is_hash: false)).to eq(':ARG')
    end

    it 'raises for private method usage' do
      foo = 'foo'
      foo.singleton_class.send(:private, :upcase)
      field = described_class.new(name: :upcase, type: S::StringType, null: true)
      expect { field.extract_value(foo, object_is_hash: false) }.to raise_error(/Private method/i)
    end

    it 'raises for values of the wrong type' do
      field = described_class.new(name: :foo, type: S::StringType, null: false)
      expect do
        field.extract_value(42, object_is_hash: false)
      end.to raise_error(Taro::RuntimeError, /Failed to coerce/)
    end
  end

  describe '#validate!' do
    let(:field) { described_class.new(name: :foo, type: S::StringType, null: false) }

    it 'does not raise if the object is valid' do
      expect { field.validate!({ foo: 'FOO' }) }.not_to raise_error
    end

    it 'raises if the object is not using symbol keys' do
      expect { field.validate!({ 'foo' => 'FOO' }) }.to raise_error(Taro::ValidationError, /is not nullable/)
    end

    it 'raises if the object is not a hash' do
      expect { field.validate!(Object.new) }.to raise_error(NoMethodError)
    end

    it 'raises if the object is missing the field' do
      expect { field.validate!({}) }.to raise_error(Taro::ValidationError)
    end

    it 'raises if the object is not matching the type' do
      expect { field.validate!({ foo: 1 }) }.to raise_error(Taro::ValidationError)
    end

    describe 'with null allowed' do
      let(:field) { described_class.new(name: :foo, type: S::StringType, null: true) }

      it 'does not raise if the object is valid' do
        expect { field.validate!({ foo: nil }) }.not_to raise_error
      end
    end

    describe 'with enum' do
      let(:field) { described_class.new(name: :foo, type: S::StringType, null: false, enum: ['FOO', 'BAR']) }

      it 'does not raise if the object is valid' do
        expect { field.validate!({ foo: 'FOO' }) }.not_to raise_error
      end

      it 'raises if the object is not matching the enum' do
        expect { field.validate!({ foo: 'BAZ' }) }.to raise_error(Taro::ValidationError)
      end

      it 'raises if the object is not matching the type' do
        expect { field.validate!({ foo: 1 }) }.to raise_error(Taro::ValidationError)
      end
    end
  end
end
