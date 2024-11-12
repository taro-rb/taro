class Taro::Rails::Railtie < ::Rails::Railtie
  initializer("taro") do |app|
    ActiveSupport.on_load(:action_controller_base) do
      ActionController::Base.prepend(Taro::Rails::ControllerExtension)
    end

    app.reloader.to_prepare do
      Taro::Rails.reset
    end
  end

  rake_tasks { Dir["#{__dir__}/tasks/**/*.rake"].each { |f| load f } }
end
