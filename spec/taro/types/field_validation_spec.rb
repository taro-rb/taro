describe Taro::Types::FieldValidation do
  let(:field) { F.new(name: :upcase, type: S::StringType, null: false) }

  it 'does not raise if the object is valid' do
    expect(field.response_validated('FOO')).to eq('FOO')
  end

  it 'raises if the object is not matching the type' do
    expect { field.response_validated(Object.new) }.to raise_error(Taro::ValidationError, /invalid type/)
  end

  it 'raises if the object is missing' do
    expect { field.response_validated(nil) }.to raise_error(Taro::ValidationError)
  end

  it 'raises if the object is not matching the type' do
    expect { field.response_validated(1) }.to raise_error(Taro::ValidationError, /invalid type/)
  end

  describe 'with null allowed' do
    let(:field) { F.new(name: :foo, type: S::StringType, null: true) }

    it 'does not raise if the object is valid' do
      expect(field.response_validated(nil)).to eq(nil)
    end
  end

  describe 'with enum' do
    let(:field) { F.new(name: :upcase, type: S::StringType, null: false, enum: ['FOO', 'BAR']) }

    it 'does not raise if the object is valid' do
      expect { field.response_validated('FOO') }.not_to raise_error
    end

    it 'raises if the object is not matching the enum' do
      expect { field.response_validated('BAZ') }.to raise_error(Taro::ValidationError, /expected one of/)
    end
  end
end
