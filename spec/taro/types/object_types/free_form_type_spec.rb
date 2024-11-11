describe Taro::Types::ObjectTypes::FreeFormType do
  describe '#coerce_input' do
    it 'returns the object if it is a hash' do
      expect(described_class.new(object: { a: 1 }).coerce_input).to eq(a: 1)
    end

    it 'raises an error if it is not a Hash' do
      expect { described_class.new(42).coerce_input }
        .to raise_error(Taro::InputError, /must be a Hash/)
    end
  end

  describe '#coerce_response' do
    it 'returns the object as a hash' do
      expect(described_class.new(object: { a: 1 }).coerce_response).to eq('a' => 1)
    end

    it 'raises an error if #as_json does not return a Hash' do
      expect { described_class.new(42).coerce_response }
        .to raise_error(Taro::ResponseError, /as_json/)
    end
  end
end
