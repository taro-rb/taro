describe Taro::Declaration do
  it 'raises NotImplementedError for #endpoint' do
    expect { subject.endpoint }.to raise_error(NotImplementedError)
  end

  it 'raises NotImplementedError for #routes' do
    expect { subject.routes }.to raise_error(NotImplementedError)
  end

  it 'has #inspect output when not finalized' do
    allow(subject).to receive(:endpoint).and_return(nil)
    expect(subject.inspect).to eq('#<Taro::Declaration (not finalized)>')
  end

  it 'has #inspect output when finalized' do
    allow(subject).to receive(:endpoint).and_return('users#show')
    expect(subject.inspect).to eq('#<Taro::Declaration (users#show)>')
  end
end
