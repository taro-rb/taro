describe Taro::Types::ListType do
  let(:example) { described_class.for(S::StringType) }

  it 'coerces input' do
    expect(example.new(%w[a]).coerce_input).to eq %w[a]
    expect(example.new([]).coerce_input).to eq []
    expect(example.new([42]).coerce_input).to be_nil
    expect(example.new('a').coerce_input).to be_nil
  end

  it 'coerces response data' do
    expect(example.new(%w[a]).coerce_response).to eq %w[a]
    expect(example.new([]).coerce_response).to eq []
    expect(example.new('a').coerce_response).to eq %w[a]
    expect(example.new(1.1).coerce_response).to be_nil
  end

  it 'has no default_nesting for scalar contents' do
    expect(example.nesting).to be_nil
  end

  it 'has a default_nesting for complex type content' do
    obj_type = Class.new(T::ObjectType)
    obj_type.define_singleton_method(:name) { 'ObjType' }
    list_type = described_class.for(obj_type)
    expect(list_type.nesting).to eq :obj_list
  end
end
