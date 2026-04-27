describe 'Taro.declarations' do
  describe '#eager_load' do
    it 'returns self' do
      expect(Taro.declarations.eager_load).to eq Taro::DeclarationsMap
    end

    it 'eager loads Rails if Rails is present' do
      stub_rails
      expect(Rails.application).to receive(:eager_load!)
      Taro.declarations.eager_load
    end

    it 'does not fail if Rails is not present' do
      expect { Taro.declarations.eager_load }.not_to raise_error
    end
  end
end
