describe Taro::Rails::DSL do
  let(:controller) { Class.new.extend(described_class) }

  it 'tracks defined_at correctly for an ad-hoc input type' do
    controller.param :foo, type: 'String', null: false
    declaration = Taro::Rails.buffered_declarations.values.last
    field = declaration.params.fields[:foo]
    expect(field.defined_at.to_s).to match(/#{__FILE__}:\d+/)
  end

  it 'tracks defined_at correctly for an ad-hoc return type' do
    controller.returns :foo, type: 'String', null: false, code: :ok
    declaration = Taro::Rails.buffered_declarations.values.last
    field = declaration.returns[200].fields[:foo]
    expect(field.defined_at.to_s).to match(/#{__FILE__}:\d+/)
  end
end
