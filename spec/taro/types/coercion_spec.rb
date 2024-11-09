describe Taro::Types::Coercion do
  describe '::from_string_or_hash!' do
    it "works with Strings" do
      expect(described_class.from_string_or_hash!('String')).to eq S::StringType
    end

    it "works with Hashes" do
      expect(described_class.from_string_or_hash!(type: 'String')).to eq S::StringType
    end

    it 'raises for unsupported inputs' do
      expect do
        described_class.from_string_or_hash!(42)
      end.to raise_error(Taro::ArgumentError, /Unsupported type/)
    end
  end

  describe '::from_string!' do
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
      it "coerces the String #{type} to a Taro type" do
        expect(described_class.from_string!(type)).to be < Taro::Types::BaseType
      end
    end

    it 'raises for unknown class names' do
      expect do
        described_class.from_string!('baddy_boy')
      end.to raise_error(Taro::ArgumentError, /Unsupported type/)
    end

    it 'raises for unsupported class names' do
      expect do
        described_class.from_string!('Object')
      end.to raise_error(Taro::ArgumentError, /Unsupported type/)
    end

    it 'raises for unsupported input' do
      expect do
        described_class.from_string!(42)
      end.to raise_error(Taro::ArgumentError, /Unsupported type/)
    end
  end

  describe '::from_hash!' do
    it 'raises for unsupported Hashes' do
      expect do
        described_class.from_hash!({})
      end.to raise_error(Taro::ArgumentError, /Unsupported type/)
    end
  end
end
