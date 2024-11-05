describe Taro::Types::ListType do
  it 'coerces input' do
    expect(S::StringType.list.new(%w[a]).coerce_input).to eq %w[a]
    expect(S::StringType.list.new([]).coerce_input).to eq []
    expect(S::StringType.list.new([42]).coerce_input).to be_nil
    expect(S::StringType.list.new('a').coerce_input).to be_nil
  end

  it 'coerces response data' do
    expect(S::StringType.list.new(%w[a]).coerce_response).to eq %w[a]
    expect(S::StringType.list.new([]).coerce_response).to eq []
    expect(S::StringType.list.new('a').coerce_response).to eq %w[a]
    expect(S::StringType.list.new(1.1).coerce_response).to be_nil
  end

  it 'has no default_nesting for scalar contents' do
    expect(S::StringType.list.nesting).to be_nil
  end

  it 'has a default_nesting for complex type content' do
    obj_type = Class.new(T::ObjectType)
    obj_type.define_singleton_method(:name) { 'ObjType' }
    expect(obj_type.list.nesting).to eq :obj_list
  end
end
