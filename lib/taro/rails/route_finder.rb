module Taro::Rails::RouteFinder
  class << self
    def call(controller_class:, action_name:)
      endpoint = "#{controller_class.controller_path}##{action_name}"
      cache[endpoint] || []
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
      # { 'users#show' => [#<NormalizedRoute>, #<NormalizedRoute>] }
      rails_routes
        .map { |r| Taro::Rails::NormalizedRoute.new(r) }
        .reject(&:ignored?)
        .group_by { |r| r.endpoint }
    end

    def rails_routes
      # make sure routes are loaded
      Rails.application.reload_routes! unless Rails.application.routes.routes.any?
      Rails.application.routes.routes
    end
  end
end
