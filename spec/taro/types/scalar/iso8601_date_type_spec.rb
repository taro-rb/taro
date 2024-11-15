describe Taro::Types::Scalar::ISO8601DateType do
  describe '#coerce_input' do
    it 'works for valid input' do
      expect(described_class.new('2024-10-24').coerce_input).to eq Date.new(2024, 10, 24)
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
      expect(described_class.new(Date.new(2024, 10, 24)).coerce_response).to eq '2024-10-24'
    end

    it 'works for valid input Time' do
      expect(described_class.new(Time.new(2024, 10, 24, 12, 0, 0)).coerce_response).to eq '2024-10-24'
    end

    it 'works for valid input DateTime' do
      expect(described_class.new(DateTime.new(2024, 10, 24, 12, 0, 0)).coerce_response).to eq '2024-10-24'
    end

    it 'fails on wrong input type' do
      expect { described_class.new('foobar').coerce_response }
        .to raise_error(Taro::ResponseError, /must be a Time, Date, or DateTime/)
    end
  end
end
