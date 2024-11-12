class Taro::Rails::Declaration
  attr_reader :description, :summary, :params, :returns, :return_descriptions, :routes, :tags

  def initialize
    @params = Class.new(Taro::Types::InputType)
    @returns = {}
    @return_descriptions = {}
  end

  def add_info(summary, description: nil, tags: nil)
    summary.is_a?(String) || raise(Taro::ArgumentError, 'api summary must be a String')
    @summary = summary
    @description = description
    @tags = Array(tags) if tags
  end

  def add_param(param_name, **kwargs)
    @params.field(param_name, **kwargs)
  end

  def add_return(field_name = nil, code:, description: nil, **kwargs)
    status = self.class.coerce_status_to_int(code)
    returns[status] &&
      raise(Taro::ArgumentError, "response for status #{status} already declared")

    returns[status] = return_type_from(field_name, **kwargs)

    # response description is required in openapi 3 – fall back to status code
    return_descriptions[status] = description || code.to_s
  end

  def parse_params(rails_params)
    hash = params.new(rails_params.to_unsafe_h).coerce_input
    hash
  end

  def openapi_paths
    routes.to_a.map do |route|
      route.path.spec.to_s.gsub(/:(\w+)/, '{\1}').gsub('(.:format)', '')
    end
  end

  def finalize(controller_class:, action_name:)
    add_routes(controller_class:, action_name:)
    add_openapi_names(controller_class:, action_name:)
  end

  def add_routes(controller_class:, action_name:)
    routes = Taro::Rails::RouteFinder.call(controller_class:, action_name:)
    routes.any? || raise_missing_route(controller_class, action_name)
    self.routes = routes
  end

  def routes=(arg)
    arg.is_a?(Array) || raise(Taro::ArgumentError, 'routes must be an Array')
    @routes = arg
  end

  # TODO: these change when the controller class is renamed.
  # We might need a way to set `base`. Perhaps as a kwarg to `::api`?
  def add_openapi_names(controller_class:, action_name:)
    base = "#{controller_class.name.chomp('Controller').sub('::', '_')}_#{action_name}"
    params.openapi_name = "#{base}_Input"
    returns.each do |status, return_type|
      return_type.openapi_name = "#{base}_#{status}_Response"
    end
  end

  require 'rack'
  def self.coerce_status_to_int(status)
    # support using http status numbers directly
    return status if ::Rack::Utils::SYMBOL_TO_STATUS_CODE.key(status)

    # support using symbols, but coerce them to numbers
    ::Rack::Utils::SYMBOL_TO_STATUS_CODE[status] ||
      raise(Taro::ArgumentError, "Invalid status: #{status.inspect}")
  end

  private

  def return_type_from(field_name, **kwargs)
    if field_name
      # TODO: allow anonymous types in openapi export, ref only their contents
      Class.new(Taro::Types::ObjectType).tap { |t| t.field(field_name, **kwargs) }
    else
      Taro::Types::Coercion.call(kwargs)
    end
  end

  def raise_missing_route(controller_class, action_name)
    raise(Taro::ArgumentError, "No route found for #{controller_class}##{action_name}")
  end
end
