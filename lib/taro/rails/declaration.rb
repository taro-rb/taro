class Taro::Rails::Declaration
  attr_reader :desc, :summary, :params, :return_defs, :return_descriptions, :return_nestings, :routes, :tags

  def initialize(for_klass = nil)
    @params = Class.new(Taro::Types::InputType)
    @return_defs = {}
    @return_descriptions = {}
    @return_nestings = {}

    Taro::Rails::CommonReturns.for(for_klass).each { |cr| add_return(**cr) }
  end

  def add_info(summary, desc: nil, tags: nil)
    summary.is_a?(String) || raise(Taro::ArgumentError, 'api summary must be a String')
    @summary = summary
    @desc = desc
    @tags = Array(tags) if tags
  end

  def add_param(param_name, **kwargs)
    @params.field(param_name, **kwargs)
  end

  def add_return(nesting = nil, code:, desc: nil, **kwargs)
    status = Taro::StatusCode.coerce_to_int(code)
    raise_if_already_declared(status)

    kwargs[:nesting] = nesting
    check_return_kwargs(kwargs)

    return_defs[status] = kwargs

    return_descriptions[status] = desc

    # if a field name is provided, the response should be nested
    return_nestings[status] = nesting if nesting
  end

  # Return types are evaluated lazily to avoid unnecessary autoloading
  # of all types in dev/test envs.
  def returns
    @returns ||= evaluate_return_defs
  end

  def raise_if_already_declared(status)
    (prev = return_defs[status]) && raise(Taro::ArgumentError, <<~MSG)
      response for status #{status} already declared at #{prev[:defined_at]}
    MSG
  end

  def parse_params(rails_params)
    params.new(rails_params.to_unsafe_h).coerce_input
  end

  def finalize(controller_class:, action_name:)
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

    bad_keys = kwargs.keys - (Taro::Types::Coercion.keys + %i[code defined_at desc nesting])
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

  def <=>(other)
    routes.first.openapi_operation_id <=> other.routes.first.openapi_operation_id
  end
end
