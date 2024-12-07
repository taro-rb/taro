describe Taro::Rails::NormalizedRoute do
  let(:example) { described_class.new(rails_route) }
  let(:rails_route) { mock_user_route }

  it 'builds an #openapi_path from the Journey::Route path spec' do
    allow(rails_route.path.spec).to receive(:to_s).and_return('/:a/b/:c(.:format)')
    expect(example.openapi_path).to eq('/{a}/b/{c}')
  end

  it 'normalizes the verb for multi-matched routes' do
    allow(rails_route).to receive(:verb).and_return('POST|GET')
    expect(example.verb).to eq 'post'
    allow(rails_route).to receive(:verb).and_return('GET|POST')
    expect(example.verb).to eq 'post'
  end

  it 'derives the endpoint from the controller and action requirements' do
    expect(example.endpoint).to eq 'users#update'
  end

  it 'is not ignored by default' do
    expect(example).not_to be_ignored
  end

  it 'is ignored if the verb is PATCH and the action is update' do
    allow(rails_route).to receive(:verb).and_return('PATCH')
    allow(rails_route.requirements).to receive(:[]).with(:action).and_return('update')
    expect(example).to be_ignored
  end

  it 'is ignored if the route has no verb (e.g. rails internal route)' do
    allow(rails_route).to receive(:verb).and_return(nil)
    expect(example).to be_ignored
  end
end
