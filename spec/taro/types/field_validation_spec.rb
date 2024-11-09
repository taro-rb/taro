describe Taro::Types::FieldValidation do
  let(:field) { F.new(name: :foo, type: S::StringType, null: false) }

  it 'does not raise if the object is valid' do
    expect { field.validate!({ foo: 'FOO' }) }.not_to raise_error
  end

  it 'raises if the object is not using symbol keys' do
    expect { field.validate!({ 'foo' => 'FOO' }) }.to raise_error(Taro::ValidationError, /is not nullable/)
  end

  it 'raises if the object is not a hash' do
    expect { field.validate!(Object.new) }.to raise_error(NoMethodError)
  end

  it 'raises if the object is missing the field' do
    expect { field.validate!({}) }.to raise_error(Taro::ValidationError)
  end

  it 'raises if the object is not matching the type' do
    expect { field.validate!({ foo: 1 }) }.to raise_error(Taro::ValidationError)
  end

  describe 'with null allowed' do
    let(:field) { F.new(name: :foo, type: S::StringType, null: true) }

    it 'does not raise if the object is valid' do
      expect { field.validate!({ foo: nil }) }.not_to raise_error
    end
  end

  describe 'with enum' do
    let(:field) { F.new(name: :foo, type: S::StringType, null: false, enum: ['FOO', 'BAR']) }

    it 'does not raise if the object is valid' do
      expect { field.validate!({ foo: 'FOO' }) }.not_to raise_error
    end

    it 'raises if the object is not matching the enum' do
      expect { field.validate!({ foo: 'BAZ' }) }.to raise_error(Taro::ValidationError)
    end

    it 'raises if the object is not matching the type' do
      expect { field.validate!({ foo: 1 }) }.to raise_error(Taro::ValidationError)
    end
  end
end
