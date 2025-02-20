class Taro::Rails::Railtie < ::Rails::Railtie
  initializer("taro") do |app|
    # The `:action_controller` hook fires for both ActionController::API
    # and ActionController::Base, executing the block in their context.
    ActiveSupport.on_load(:action_controller) do
      extend Taro::Rails::DSL
    end

    app.reloader.to_prepare do
      Taro::Rails.reset
    end

    app.config.after_initialize do
      Taro::Cache.cache_instance = Rails.cache
    end
  end

  rake_tasks { Dir["#{__dir__}/tasks/**/*.rake"].each { |f| load f } }
end
