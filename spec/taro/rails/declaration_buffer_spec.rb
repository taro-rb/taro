describe Taro::Rails::DeclarationBuffer do
  it 'raises if an endpoint has a declaration but no route pointing to it' do
    buffer = Object.extend(described_class)
    controller_class = Class.new
    buffer.buffered_declaration(controller_class)
    allow(Taro::Rails::RouteFinder).to receive(:call).and_return([])

    expect do
      buffer.apply_buffered_declaration(controller_class, :create)
    end.to raise_error(Taro::Error, /No route found for .*#create/i)
  end
end
