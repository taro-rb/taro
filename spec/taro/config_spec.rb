describe Taro::Config do
  describe '::invalid_response_callback' do
    it 'warns by default if Rails is not present' do
      stub_const('Rails', nil)
      expect do
        described_class.invalid_response_callback.call('msg', 'details')
      end.to output(/msg/).to_stderr
    end

    it 'warns by default in Rails production' do
      allow(Rails.env).to receive(:production?).and_return(true)
      expect do
        described_class.invalid_response_callback.call('msg', 'details')
      end.to output(/msg/).to_stderr
    end

    it 'raises by default in Rails dev/test/stg' do
      allow(Rails.env).to receive(:production?).and_return(false)
      expect do
        described_class.invalid_response_callback.call('msg', 'details')
      end.to raise_error(Taro::ResponseValidationError)
    end

    it 'can be customized' do
      Taro.config.invalid_response_callback = ->(*) { print 'hi' }
      allow(Rails.env).to receive(:production?).and_return(false)
      expect do
        described_class.invalid_response_callback.call('msg', 'details')
      end.to output('hi').to_stdout
    ensure
      Taro.config.invalid_response_callback = Taro.config.default_invalid_response_callback
    end
  end
end
