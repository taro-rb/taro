describe Taro::Types::Shared::Fields do
  let(:example) do
    klass = Class.new.extend(described_class)
    klass.field(:foo) { [String, null: false] }
    klass
  end

  it 'adds field capabilitites to classes' do
    expect(example.fields.keys).to eq %i[foo]

    field = example.fields[:foo]
    expect(field.name).to eq :foo
    expect(field.type).to eq S::StringType
    expect(field.null).to eq false
  end

  it 'raises when trying to create fields without a block' do
    expect { example.field(:bar) }.to raise_error(Taro::Error, /block/)
  end

  it 'raises when evaluating fields without type' do
    example.field(:bar) { { null: true } }
    expect { example.fields }.to raise_error(Taro::Error, /type/)
  end

  it 'raises when evaluating fields without null' do
    example.field(:bar) { { type: String } }
    expect { example.fields }.to raise_error(Taro::Error, /null/)
  end

  it 'raises when redefining fields' do
    example.field(:bar) { {} }
    expect { example.field(:bar) { {} } }.to raise_error(Taro::Error, /defined/)
  end
end
