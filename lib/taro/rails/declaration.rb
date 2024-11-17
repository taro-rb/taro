class Taro::Rails::Declaration
  attr_reader :desc, :summary, :params, :return_defs, :return_descriptions, :return_nestings, :routes, :tags

  def initialize
    @params = Class.new(Taro::Types::InputType)
    @return_defs = {}
    @return_descriptions = {}
    @return_nestings = {}
  end

  def add_info(summary, desc: nil, tags: nil)
    summary.is_a?(String) || raise(Taro::ArgumentError, 'api summary must be a String')
    @summary = summary
    @desc = desc
    @tags = Array(tags) if tags
  end

  def add_param(param_name, **kwargs)
    kwargs[:defined_at] = caller_locations(1..2)[1]
    @params.field(param_name, **kwargs)
  end

  def add_return(nesting = nil, code:, desc: nil, **kwargs)
    status = self.class.coerce_status_to_int(code)
    raise_if_already_declared(status)

    kwargs[:nesting] = nesting
    check_return_kwargs(kwargs)

    kwargs[:defined_at] = caller_locations(1..2)[1]
    return_defs[status] = kwargs

    # response desc is required in openapi 3 – fall back to status code
    return_descriptions[status] = desc || code.to_s

    # if a field name is provided, the response should be nested
    return_nestings[status] = nesting if nesting
  end

  # Return types are evaluated lazily to avoid unnecessary autoloading
  # of all types in dev/test envs.
  def returns
    @returns ||= evaluate_return_defs
  end

  def raise_if_already_declared(status)
    return_defs[status] &&
      raise(Taro::ArgumentError, "response for status #{status} already declared")
  end

  def parse_params(rails_params)
    hash = params.new(rails_params.to_unsafe_h).coerce_input
    hash
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

  def polymorphic_route?
    routes.size > 1
  end

  # TODO: these change when the controller class is renamed.
  # We might need a way to set `base`. Perhaps as a kwarg to `::api`?
  def add_openapi_names(controller_class:, action_name:)
    base = "#{controller_class.name.chomp('Controller').gsub('::', '_')}_#{action_name}"
    params.openapi_name = "#{base}_Input"
    params.define_singleton_method(:name) { openapi_name }

    returns.each do |status, return_type|
      next if return_type.openapi_name? # only set for ad-hoc / nested return types

      return_type.openapi_name = "#{base}_#{status}_Response"
      return_type.define_singleton_method(:name) { openapi_name }
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

  def check_return_kwargs(kwargs)
    # For nested returns, evaluate_return_def calls ::field, which validates
    # field options, but does not trigger type autoloading.
    return evaluate_return_def(**kwargs) if kwargs[:nesting]

    if kwargs.key?(:null)
      raise Taro::ArgumentError, <<~MSG
        `null:` is not supported for top-level returns. If you want a nullable return
        value, nest it, e.g. `returns :str, type: 'String', null: true`.
      MSG
    end

    bad_keys = kwargs.keys - (Taro::Types::Coercion.keys + %i[code desc nesting])
    return if bad_keys.empty?

    raise Taro::ArgumentError, "Invalid `returns` options: #{bad_keys.join(', ')}"
  end

  def evaluate_return_defs
    return_defs.transform_values { |defi| evaluate_return_def(**defi) }
  end

  def evaluate_return_def(nesting:, **kwargs)
    if nesting
      # ad-hoc return type, requiring the actual return type to be nested
      Class.new(Taro::Types::ObjectType).tap do |type|
        type.field(nesting, null: false, **kwargs)
      end
    else
      Taro::Types::Coercion.call(kwargs)
    end
  end

  def raise_missing_route(controller_class, action_name)
    raise(Taro::ArgumentError, "No route found for #{controller_class}##{action_name}")
  end
end
