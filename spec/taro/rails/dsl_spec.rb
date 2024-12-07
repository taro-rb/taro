describe Taro::Rails::DSL do
  let(:controller) { stub_const('C', Class.new.extend(described_class)) }

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

  it 'applies buffered declarations when methods are added',
     config: { parse_params: false, validate_response: false } do
    controller.api 'My summary'
    allow(Taro::Rails::RouteFinder).to receive(:call).and_return([:route])
    expect { controller.define_method(:foo) { nil } }
      .to change { Taro.declarations.count }.by(1)
  end

  it 'does not fail if actions are defined without buffered declarations' do
    expect { controller.define_method(:foo) { nil } }
      .to change { Taro.declarations.count }.by(0)
  end
end
