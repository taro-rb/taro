describe Taro::Rails::ResponseValidation do
  it 'installs a before_action on the controller class, but only once' do
    controller_class = Class.new
    controller_class.define_singleton_method(:after_action) { |*| nil }
    expect(controller_class).to receive(:after_action).once
    2.times { described_class.install(controller_class:, action_name: :index) }
  end

  it 'does not install the after_action if param parsing is disabled', config: { validate_response: false } do
    controller_class = Class.new
    controller_class.define_singleton_method(:after_action) { |*| nil }
    expect(controller_class).not_to receive(:after_action)
    described_class.install(controller_class:, action_name: :index)
  end
end