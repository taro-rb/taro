describe Taro::Types::Shared::Equivalence do
  let(:type1) { Class.new(S::StringType) }
  let(:type2) { Class.new(S::StringType) }

  it 'is true when objects are the same' do
    expect(type1.equivalent?(type1)).to be true
  end

  it 'is true when types are equivalent' do
    expect(type1.equivalent?(type2)).to be true
  end

  it 'is true for equivalent object types' do
    # see field_def_spec.rb for detailed field equality specs
    type1 = Class.new(T::ObjectType) { field :foo, type: 'String', null: false }
    type2 = Class.new(T::ObjectType) { field :foo, type: 'String', null: false }
    expect(type1.equivalent?(type2)).to be true

    type3 = Class.new(T::ObjectType) { field :foo, type: 'String', null: false }
    type4 = Class.new(T::ObjectType) { field :foo, type: 'Integer', null: false }
    expect(type3.equivalent?(type4)).to be false
  end

  it 'is false when other has a different openapi_type' do
    type2.openapi_type = :object
    expect(type1.equivalent?(type2)).to be false
  end

  it 'is false when other has a different openapi_name' do
    type2.openapi_name = 'Run DMC'
    expect(type1.equivalent?(type2)).to be false
  end

  it 'is false when other has different attributes' do
    type2.pattern = /its tricky/
    expect(type1.equivalent?(type2)).to be false
  end

  it 'ignores derived_types' do
    type1.derived_types[:foo] = :foo
    type2.derived_types[:bar] = :bar
    expect(type1.equivalent?(type2)).to be true
  end
end
