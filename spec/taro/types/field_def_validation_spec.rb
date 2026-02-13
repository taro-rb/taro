describe Taro::Types::FieldDefValidation do
  def validate(**attributes)
    Taro::Types::FieldDef.new(**attributes)
  end

  it 'raises without type' do
    expect { validate(name: :bar) }
      .to raise_error(Taro::ArgumentError, /type.*must be given/)
  end

  it 'raises with non-string type' do
    expect { validate(name: :bar, type: 23) }
      .to raise_error(Taro::ArgumentError, /type must be a String/)
  end

  it 'raises with multiple type keys' do
    expect { validate(name: :bar, type: 'String', array_of: 'String') }
      .to raise_error(Taro::ArgumentError, /Exactly one of type, .* must be given/)
  end

  it 'accepts null: false' do
    expect(validate(name: :bar, type: 'String', null: false).attributes[:null]).to eq(false)
  end

  it 'accepts null: true' do
    expect(validate(name: :bar, type: 'String', null: true).attributes[:null]).to eq(true)
  end

  it 'raises if null is not specified and no default is set', config: { default_value_for_null: nil } do
    expect { validate(name: :bar, type: 'String') }
      .to raise_error(Taro::ArgumentError, /null has to be specified/)
  end

  it 'raises with non-boolean null' do
    expect { validate(name: :bar, type: 'String', null: 'yes') }
      .to raise_error(Taro::ArgumentError, /null/)
  end

  it 'accepts required: true' do
    expect(validate(name: :bar, type: 'String', required: true).attributes[:required]).to eq(true)
  end

  it 'accepts required: false' do
    expect(validate(name: :bar, type: 'String', required: false).attributes[:required]).to eq(false)
  end

  it 'raises if required is not specified and no default is set', config: { default_value_for_required: nil } do
    expect { validate(name: :bar, type: 'String') }
      .to raise_error(Taro::ArgumentError, /required has to be specified/)
  end

  it 'raises with non-boolean required' do
    expect { validate(name: :bar, type: 'String', required: 'yes') }
      .to raise_error(Taro::ArgumentError, /required/)
  end

  it 'raises with required: true and a default' do
    expect { validate(name: :bar, type: 'String', required: true, default: 'x') }
      .to raise_error(Taro::ArgumentError, /required.*cannot be combined with a default/)
  end
end
