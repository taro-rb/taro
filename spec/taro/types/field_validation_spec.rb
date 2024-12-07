describe Taro::Types::FieldValidation do
  let(:field) { F.new(name: :upcase, type: S::StringType, null: false) }

  it 'does not raise if the object is valid' do
    expect(field.validated_value('FOO')).to eq('FOO')
  end

  it 'raises if the object is missing' do
    expect { field.validated_value(nil) }.to raise_error(
      Taro::InputError,
      'NilClass is not valid as StringType: field is not nullable',
    )
  end

  it 'raises ResponseError if the object is missing for a response' do
    expect { field.validated_value(nil, false) }.to raise_error(
      Taro::ResponseError,
      'NilClass is not valid as StringType: field is not nullable',
    )
  end

  describe 'with null allowed' do
    let(:field) { F.new(name: :foo, type: S::StringType, null: true) }

    it 'does not raise if the object is valid' do
      expect(field.validated_value(nil)).to eq(nil)
    end
  end

  describe 'with enum' do
    let(:field) { F.new(name: :upcase, type: S::StringType, null: false, enum: %w[A B]) }

    it 'does not raise if the object is valid' do
      expect { field.validated_value('A') }.not_to raise_error
    end

    it 'does not raise if the field is nullable and value is nil' do
      field =  F.new(name: :upcase, type: S::StringType, null: true, enum: %w[A B])
      expect { field.validated_value(nil) }.not_to raise_error
    end

    it 'raises if the object is not matching the enum' do
      expect { field.validated_value('C') }.to raise_error(
        Taro::InputError,
        'String is not valid as StringType: field expects one of ["A", "B"], got "C"',
      )
    end

    it 'raises if the object is not matching the enum for a response' do
      expect { field.validated_value('C', false) }.to raise_error(
        Taro::ResponseError,
        'String is not valid as StringType: field expects one of ["A", "B"], got "C"',
      )
    end
  end
end
