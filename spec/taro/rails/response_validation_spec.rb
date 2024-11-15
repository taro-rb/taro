describe Taro::Rails::ResponseValidation do
  let(:controller_class) { Class.new }
  let(:controller) { controller_class.new }
  before { controller_class.define_method(:render) { |*| :original_result } }

  describe '::install' do
    it 'installs a validation on the controller class, but only once' do
      expect { 2.times { described_class.install(controller_class:) } }
        .to change { controller_class.ancestors.count { |a| a == described_class } }
        .from(0).to(1)
    end

    it 'does not install the validation if it is disabled', config: { validate_response: false } do
      described_class.install(controller_class:)
      expect(controller_class.ancestors).not_to include(described_class)
    end
  end

  describe '#render' do
    it 'patches Controller#render to call the ResponseValidator' do
      described_class.install(controller_class:)
      allow(Taro::Rails).to receive(:declaration_for).and_return(:decl)

      expect(Taro::Rails::ResponseValidator)
        .to receive(:call).with(controller, :decl, :json_arg)
      expect(controller.render(json: :json_arg)).to eq(:original_result)
    end

    it 'does not call the ResponseValidator if the endpoint is undeclared' do
      described_class.install(controller_class:)
      allow(Taro::Rails).to receive(:declaration_for).and_return(nil)

      expect(Taro::Rails::ResponseValidator).not_to receive(:call)
      expect(controller_class.new.render(json: :json_arg)).to eq(:original_result)
    end
  end
end
