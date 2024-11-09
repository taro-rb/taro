describe Taro::Types::Coercion do
  describe '::call' do
    %w[
      Boolean
      Date
      DateTime
      Float
      Integer
      String
      Time
      UUID
    ].each do |type|
      it "coerces { type: '#{type}' } to a Taro type" do
        expect(described_class.call(type:)).to be < T::BaseType
      end
    end

    it 'works with array_of' do
      expect(described_class.call(array_of: 'String'))
        .to eq T::ListType.for(S::StringType)
    end

    it 'works with page_of' do
      expect(described_class.call(page_of: 'String'))
        .to eq T::ObjectTypes::PageType.for(S::StringType)
    end

    it 'raises for unknown class names' do
      expect do
        described_class.call(type: 'baddy_boy')
      end.to raise_error(Taro::ArgumentError, /Unsupported type/)
    end

    it 'raises for unsupported class names' do
      expect do
        described_class.call(type: 'Object')
      end.to raise_error(Taro::ArgumentError, /Unsupported type/)
    end

    it 'raises for unsupported input' do
      expect do
        described_class.call(type: 42)
      end.to raise_error(Taro::ArgumentError, /Unsupported type/)
    end

    it 'raises for Hashes without type info' do
      expect do
        described_class.call({})
      end.to raise_error(Taro::ArgumentError, /must be given/)
    end

    it 'raises for Hashes with too much type info' do
      expect do
        described_class.call({ array_of: 'String', page_of: 'String' })
      end.to raise_error(Taro::ArgumentError, /exactly one/i)
    end

    it 'raises for unexpected from_hash arguments' do
      expect { described_class.send(:from_hash, {}) }
        .to raise_error(NotImplementedError)
    end
  end
end
