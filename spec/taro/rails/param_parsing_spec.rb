describe Taro::Rails::ParamParsing do
  it 'installs a before_action on the controller class, but only once' do
    controller_class = Class.new
    controller_class.define_singleton_method(:before_action) { |*| nil }
    expect(controller_class).to receive(:before_action).once
    2.times { described_class.install(controller_class:, action_name: :index) }
  end

  it 'does not install the before_action if param parsing is disabled' do
    orig = Taro.config.parse_params
    Taro.config.parse_params = false

    controller_class = Class.new
    controller_class.define_singleton_method(:before_action) { |*| nil }
    expect(controller_class).not_to receive(:before_action)
    described_class.install(controller_class:, action_name: :index)
  ensure
    Taro.config.parse_params = orig
  end
end
