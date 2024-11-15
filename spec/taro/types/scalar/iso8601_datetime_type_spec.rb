describe Taro::Types::Scalar::ISO8601DateTimeType do
  describe '#coerce_input' do
    it 'works for valid input' do
      expect(described_class.new('2024-10-24T12:00:00Z').coerce_input).to eq DateTime.new(2024, 10, 24, 12, 0, 0)
    end

    it 'fails on wrong input type' do
      expect { described_class.new(2025).coerce_input }
        .to raise_error(Taro::InputError, /must be a ISO8601 formatted string/)
    end

    it 'fails on wrong input format' do
      expect { described_class.new('2025').coerce_input }
        .to raise_error(Taro::InputError, /must be a ISO8601 formatted string/)
    end
  end

  describe '#coerce_response' do
    it 'works for valid input Date' do
      expect(described_class.new(Date.new(2024, 10, 24)).coerce_response).to eq '2024-10-24T00:00:00Z'
    end

    it 'works for valid input Time and converts to UTC if necessary' do
      time = Time.new(2024, 10, 24, 15, 45, 0, "+03:00")
      expect(described_class.new(time).coerce_response).to eq '2024-10-24T12:45:00Z'
    end

    it 'works for valid input DateTime' do
      expect(described_class.new(DateTime.new(2024, 10, 24, 12, 0, 0)).coerce_response).to eq '2024-10-24T12:00:00Z'
    end

    it 'fails on wrong input type' do
      expect { described_class.new('foobar').coerce_response }
        .to raise_error(Taro::ResponseError, /must be a Time, Date, or DateTime/)
    end
  end
end
