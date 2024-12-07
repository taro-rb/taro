describe Taro::Rails::ParamParsing do
  require 'action_controller'

  let(:controller_class) { Class.new(ActionController::Base) }

  describe '::install' do
    it 'installs a before_action on the controller class, but only once' do
      expect(controller_class).to receive(:prepend_before_action).once
      2.times { described_class.install(controller_class:, action_name: :index) }
    end

    it 'does not install the before_action if param parsing is disabled', config: { parse_params: false } do
      expect(controller_class).not_to receive(:prepend_before_action)
      described_class.install(controller_class:, action_name: :index)
    end
  end

  describe 'parsing' do
    let(:controller) { controller_class.new }
    let(:declaration) { Taro::Rails::Declaration.new }

    before do
      stub_const('UserInputType', Class.new(T::InputType) do
        field :name, type: 'String', null: false
      end)
      declaration.add_param :user, type: 'UserInputType', null: true
      allow(Taro::Rails).to receive(:declaration_for).and_return(declaration)
      described_class.install(controller_class:, action_name: :index)

      controller.define_singleton_method(:action_name) { 'index' }
      controller.define_singleton_method(:performed?) { false }
    end

    it 'coerces the params' do
      allow(controller)
        .to receive(:params)
        .and_return(ActionController::Parameters.new(user: { name: 'Alice' }))

      controller.run_callbacks(:process_action)

      expect(controller.instance_variable_get(:@api_params))
        .to eq(user: { name: 'Alice' })
    end

    it 'raises for invalid params' do
      allow(controller)
        .to receive(:params)
        .and_return(ActionController::Parameters.new(user: { name: nil }))

      expect do
        controller.run_callbacks(:process_action)
      end.to raise_error(Taro::InputError, /NilClass is not valid as String/)
    end
  end
end
