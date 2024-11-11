describe Taro::Types::FieldValidation do
  let(:field) { F.new(name: :upcase, type: S::StringType, null: false) }

  it 'does not raise if the object is valid' do
    expect(field.validated_value('FOO')).to eq('FOO')
  end

  it 'raises if the object is missing' do
    expect { field.validated_value(nil) }.to raise_error(Taro::ValidationError)
  end

  describe 'with null allowed' do
    let(:field) { F.new(name: :foo, type: S::StringType, null: true) }

    it 'does not raise if the object is valid' do
      expect(field.validated_value(nil)).to eq(nil)
    end
  end

  describe 'with enum' do
    let(:field) { F.new(name: :upcase, type: S::StringType, null: false, enum: ['FOO', 'BAR']) }

    it 'does not raise if the object is valid' do
      expect { field.validated_value('FOO') }.not_to raise_error
    end

    it 'raises if the object is not matching the enum' do
      expect { field.validated_value('BAZ') }.to raise_error(Taro::ValidationError, /expected one of/)
    end
  end
end
