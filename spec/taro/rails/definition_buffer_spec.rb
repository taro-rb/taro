describe Taro::Rails::DefinitionBuffer do
  it 'raises if an endpoint has a definition but no route pointing to it' do
    buffer = Object.extend(described_class)
    controller_class = :dummy
    buffer.buffered_definition(controller_class)
    allow(Taro::Rails::RouteFinder).to receive(:call).and_return([])

    expect do
      buffer.apply_buffered_definition(controller_class, :create)
    end.to raise_error(Taro::Error, /route.*dummy#create/i)
  end
end
