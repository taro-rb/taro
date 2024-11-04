class Taro::Rails::Railtie < ::Rails::Railtie
  initializer("taro") do |_app|
    ActiveSupport.on_load(:action_controller_base) do
      ActionController::Base.prepend(Taro::Rails::ControllerExtension)
    end
  end
end
