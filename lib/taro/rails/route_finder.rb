module Taro::Rails::RouteFinder
  class << self
    def call(controller_class:, action_name:)
      cache["#{controller_class.controller_path}##{action_name}"] || []
    end

    def clear_cache
      @cache = nil
    end

    private

    def cache
      @cache ||= build_cache
    end

    def build_cache
      # Build a Hash like
      # { 'users#show' } => [#<NormalizedRoute>, #<NormalizedRoute>] }
      routes.each_with_object({}) do |rails_route, hash|
        route = Taro::Rails::NormalizedRoute.new(rails_route:)
        next unless route.ok?

        (hash[route.endpoint] ||= []) << route
      end
    end

    def routes
      # make sure routes are loaded
      Rails.application.reload_routes! unless Rails.application.routes.routes.any?
      Rails.application.routes.routes
    end
  end
end
