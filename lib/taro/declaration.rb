# Framework-agnostic, abstract class.
# Descendants must implement #endpoint and (only for openapi export) #routes.
# See Taro::Rails::Declaration for an example.
class Taro::Declaration
  attr_reader :desc, :summary, :params, :return_defs, :return_descriptions, :tags

  def initialize(for_klass = nil)
    @params = Class.new(Taro::Types::InputType)
    @return_defs = {}
    @return_descriptions = {}

    Taro::CommonReturns.for(for_klass).each { |rd| add_return_def(rd) }
  end

  def add_info(summary, desc: nil, tags: nil)
    summary.is_a?(String) || raise(Taro::ArgumentError, 'api summary must be a String')
    @summary = summary
    @desc = desc
    @tags = Array(tags) if tags
  end

  def add_param(param_name, **attributes)
    if attributes[:type] == 'Integer'
      attributes[:type] = 'Taro::Types::Scalar::IntegerParamType'
    end
    @params.field(param_name, **attributes)
  end

  def add_return(nesting = nil, **)
    return_def = Taro::ReturnDef.new(nesting:, **)
    add_return_def(return_def)
  end

  # Return types are evaluated lazily to avoid unnecessary autoloading
  # of all types in dev/test envs.
  def returns
    @returns ||= evaluate_return_defs
  end

  def routes
    raise NotImplementedError, "implement ##{__method__} in subclass"
  end

  def endpoint
    raise NotImplementedError, "implement ##{__method__} in subclass"
  end

  def polymorphic_route?
    routes.size > 1
  end

  def inspect
    "#<#{self.class} (#{endpoint || 'not finalized'})>"
  end

  private

  def add_return_def(return_def)
    raise_if_already_declared(return_def.code)

    return_defs[return_def.code] = return_def
    return_descriptions[return_def.code] = return_def.desc
  end

  def raise_if_already_declared(code)
    (prev = return_defs[code]) && raise(Taro::ArgumentError, <<~MSG)
      response for status #{code} already declared at #{prev.defined_at}
    MSG
  end

  def evaluate_return_defs
    return_defs.transform_values do |rd|
      type = rd.evaluate
      type.define_name("ResponseType(#{endpoint})") if rd.nesting
      type
    end
  end

  def <=>(other)
    routes.first.openapi_operation_id <=> other.routes.first.openapi_operation_id
  end
end
