class Taro::Rails::Declaration < Taro::Declaration
  attr_reader :controller_class, :action_name

  def finalize(controller_class:, action_name:)
    @controller_class = controller_class
    @action_name = action_name
    @params.define_name("InputType(#{endpoint})")
  end

  def endpoint
    action_name && "#{controller_class}##{action_name}"
  end

  def routes
    @routes ||= Taro::Rails::RouteFinder.call(controller_class:, action_name:)
  end
end
