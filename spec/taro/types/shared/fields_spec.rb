describe Taro::Types::Shared::Fields do
  let(:example) do
    klass = Class.new.extend(described_class)
    klass.field :foo, type: 'String', null: false
    klass
  end

  it 'adds field capabilitites to classes' do
    expect(example.fields.keys).to eq %i[foo]

    field = example.fields[:foo]
    expect(field.name).to eq :foo
    expect(field.type).to eq S::StringType
    expect(field.null).to eq false
  end

  it 'raises when evaluating fields without type' do
    expect { example.field :bar, null: true }.to raise_error(Taro::ArgumentError, /type/)
  end

  it 'raises when evaluating fields without null' do
    expect { example.field :bar, type: 'String' }.to raise_error(Taro::Error, /null/)
  end

  it 'raises when redefining fields' do
    example.field :bar, type: 'String', null: true
    expect { example.field :bar, type: 'Boolean', null: false }.to raise_error(Taro::Error, /defined/)
  end

  it 'takes array_of instead of type' do
    example.field :bar, array_of: 'String', null: true
    field = example.fields[:bar]
    expect(field.type).to be < Taro::Types::ListType
  end

  it 'takes page_of instead of type' do
    example.field :bar, page_of: 'Integer', null: true
    field = example.fields[:bar]
    expect(field.type).to be < Taro::Types::ObjectTypes::PageType
  end
end
