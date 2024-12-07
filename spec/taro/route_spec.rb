describe Taro::Route do
  let(:valid_args) do
    { endpoint: 'foo', openapi_operation_id: 'bar', openapi_path: '/qux', verb: 'get' }
  end

  it 'raises when initialized with non-string args' do
    expect { described_class.new(**valid_args.merge(endpoint: 42)) }
      .to raise_error(Taro::ArgumentError)
  end

  it 'extracts #path_params from the openapi_path spec' do
    route = described_class.new(**valid_args.merge(openapi_path: '/{a}/b/{c}'))
    expect(route.path_params).to eq [:a, :c]
  end

  it 'has #inspect output' do
    route = described_class.new(**valid_args)
    expect(route.inspect).to eq '#<Taro::Route "get /qux">'
  end
end
