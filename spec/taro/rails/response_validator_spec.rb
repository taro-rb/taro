describe Taro::Rails::ResponseValidator do
  let(:controller) do
    ctrl = Object.new
    ctrl.define_singleton_method(:action_name) { "show" }
    ctrl
  end

  it 'does nothing if invalid_response_callback is disabled' do
    Taro.config.invalid_response_callback = nil
    validator = described_class.new(controller:, render_kwargs: {})
    expect(validator).not_to receive(:find_definition)
    validator.call
  ensure
    Taro.config.invalid_response_callback = Taro.config.default_invalid_response_callback
  end

  it 'does nothing if there is no api definition for the action' do
    validator = described_class.new(controller: controller, render_kwargs: {})
    expect(validator).not_to receive(:validate_with_definition)
    validator.call
  end

  context 'if there is a definition' do
    let(:definition) do
      Taro::Rails::Definition.new.tap do |defi|
        defi.accepts = 'String'
        defi.returns = { ok: 'String' }
      end
    end
    before { Taro::Rails.definitions[controller.class] = { show: definition } }

    it 'does nothing if the response matches the schema' do
      validator = described_class.new(controller: controller, render_kwargs: { json: 'ok' })
      expect(validator).not_to receive(:report)
      validator.call
    end

    it 'reports if there is no response definition for this status code' do
      validator = described_class.new(controller: controller, render_kwargs: { json: 'ok', status: 201 })
      expect(validator).to receive(:report).with("Response status not defined in response schema.", anything)
      validator.call
    end

    it 'reports if the response is not JSON' do
      validator = described_class.new(controller: controller, render_kwargs: {})
      expect(validator).to receive(:report).with("Response is not JSON.", anything)
      validator.call
    end

    it 'reports if the response does not match the schema' do
      validator = described_class.new(controller: controller, render_kwargs: { json: 123 })
      expect(validator).to receive(:report).with("Response does not match response schema.", anything)
      validator.call
    end

    it 'reports if coercion raises an error' do
      expect(S::StringType).to receive(:new).and_raise(Taro::Error, 'whatever')
      validator = described_class.new(controller: controller, render_kwargs: { json: 'ok' })
      expect(validator).to receive(:report).with("Response does not match response schema.", anything)
      validator.call
    end

    it 'reports unrelated errors' do
      expect(S::StringType).to receive(:new).and_raise('something else')
      validator = described_class.new(controller: controller, render_kwargs: { json: 'ok' })
      expect(validator).to receive(:report).with("Unhandled error when trying to validate response.", anything)
      validator.call
    end
  end

  describe '#report' do
    it 'calls the invalid_response_callback' do
      allow(Taro.config.invalid_response_callback).to receive(:call)
      described_class.new(controller: controller, render_kwargs: {}).report('msg', 'details')
      expect(Taro.config.invalid_response_callback)
        .to have_received(:call)
        .with('Response validation error in Object#show: msg', 'details')
    end
  end
end
