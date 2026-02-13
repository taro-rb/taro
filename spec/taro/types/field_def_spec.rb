# see ./field_def_validation_spec.rb for validation tests
describe Taro::Types::FieldDef do
  describe '#==' do
    it 'is true for equal defs' do
      field1 = described_class.new(name: :foo, type: 'String')
      field2 = described_class.new(name: :foo, type: 'String')
      expect(field1).to eq(field2)
    end

    it 'ignores defined_at' do
      field1 = described_class.new(name: :foo, type: 'String', defined_at: 'A')
      field2 = described_class.new(name: :foo, type: 'String', defined_at: 'B')
      expect(field1).to eq(field2)
    end

    it 'is false for different types' do
      field1 = described_class.new(name: :foo, type: 'String')
      field2 = described_class.new(name: :foo, type: 'Integer')
      expect(field1).not_to eq(field2)
    end

    it 'is false for different null' do
      field1 = described_class.new(name: :foo, type: 'String')
      field2 = described_class.new(name: :foo, type: 'String', null: true)
      expect(field1).not_to eq(field2)
    end

    it 'is false for non-defs' do
      field = described_class.new(name: :foo, type: 'String')
      expect(field).not_to eq('foo')
    end
  end
end
