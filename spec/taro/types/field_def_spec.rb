describe Taro::Types::FieldDef do
  describe '#initialize' do
    it 'raises without type' do
      expect { described_class.new name: :bar, null: true }
        .to raise_error(Taro::ArgumentError, /type.*must be given/)
    end

    it 'raises with non-string type' do
      expect { described_class.new name: :bar, type: 23, null: true }
        .to raise_error(Taro::ArgumentError, /type must be a String/)
    end

    it 'raises with multiple type keys' do
      expect { described_class.new name: :bar, type: 'String', array_of: 'String', null: true }
        .to raise_error(Taro::ArgumentError, /Exactly one of type, .* must be given/)
    end

    it 'raises without null' do
      expect { described_class.new name: :bar, type: 'String' }
        .to raise_error(Taro::Error, /null/)
    end
  end

  describe '#==' do
    it 'is true for equal defs' do
      field1 = described_class.new(name: :foo, type: 'String', null: false)
      field2 = described_class.new(name: :foo, type: 'String', null: false)
      expect(field1).to eq(field2)
    end

    it 'ignores defined_at' do
      field1 = described_class.new(name: :foo, type: 'String', null: false, defined_at: 'A')
      field2 = described_class.new(name: :foo, type: 'String', null: false, defined_at: 'B')
      expect(field1).to eq(field2)
    end

    it 'is false for different types' do
      field1 = described_class.new(name: :foo, type: 'String', null: false)
      field2 = described_class.new(name: :foo, type: 'Integer', null: false)
      expect(field1).not_to eq(field2)
    end

    it 'is false for different null' do
      field1 = described_class.new(name: :foo, type: 'String', null: false)
      field2 = described_class.new(name: :foo, type: 'String', null: true)
      expect(field1).not_to eq(field2)
    end

    it 'is false for non-defs' do
      field = described_class.new(name: :foo, type: 'String', null: false)
      expect(field).not_to eq('foo')
    end
  end
end
