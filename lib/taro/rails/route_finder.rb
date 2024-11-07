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
      # { { controller: 'users', action: 'show', verb: 'GET' } => #<Route> }
      routes_by_attributes = map_routes_by_attributes

      # Rails has both PATCH and PUT routes for updates. We only need one copy.
      routes_by_attributes.reject! do |attrs, _route|
        attrs[:verb] == 'PATCH' && routes_by_attributes[attrs.merge(verb: 'PUT')]
      end

      # Build a Hash like
      # { 'users#show' } => [#<Route>, #<Route>] }
      routes_by_attributes.each_with_object({}) do |(attrs, route), map|
        (map["#{attrs[:controller]}##{attrs[:action]}"] ||= []) << route
      end
    end

    def map_routes_by_attributes
      routes.each_with_object({}) do |route, map|
        # Route#verb is a String. Its usually something like 'POST', but manual
        # matched routes may have e.g. 'GET|POST' (🤢). We only need one copy.
        verb = route.verb.to_s.scan(/\w+/).sort.last
        next unless verb

        # The #requirements Hash contains :controller (an underscored
        # controller name) and :action (the action name as String, e.g. 'show').
        attrs = route.requirements.slice(:controller, :action).merge(verb:)
        map[attrs] = route
      end
    end

    def routes
      # make sure routes are loaded
      Rails.application.reload_routes! unless Rails.application.routes.routes.any?
      Rails.application.routes.routes
    end
  end
end
