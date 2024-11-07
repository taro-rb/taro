module Taro::Types::CoerceToType
  class << self
    def call(arg)
      case arg
      when Class  then from_class(arg)
      when Hash   then from_hash(arg)
      when String then from_string(arg)
      end || raise_cast_error(arg)
    end

    def from_hash(arg)
      if arg[:type]
        call(arg[:type])
      elsif (inner_type = arg[:array_of])
        Taro::Types::ListType.for(call(inner_type))
      elsif (inner_type = arg[:page_of])
        Taro::Types::ObjectTypes::PageType.for(call(inner_type))
      end
    end

    private

    def from_class(arg)
      arg if arg < Taro::Types::BaseType
    end

    def from_string(arg)
      shortcuts[arg] ||
        Object.const_defined?(arg) && call(Object.const_get(arg))
    end

    # Map some Ruby class names and other shortcuts to built-in types
    # to support e.g. `returns 'String'`, or `field :foo, type: 'Boolean'` etc.
    require 'date'
    def shortcuts
      @shortcuts ||= {
        # rubocop:disable Layout/HashAlignment - buggy cop
        'Boolean'  => Taro::Types::Scalar::BooleanType,
        'Date'     => Taro::Types::Scalar::TimestampType,
        'DateTime' => Taro::Types::Scalar::TimestampType,
        'Float'    => Taro::Types::Scalar::FloatType,
        'Integer'  => Taro::Types::Scalar::IntegerType,
        'String'   => Taro::Types::Scalar::StringType,
        'Time'     => Taro::Types::Scalar::TimestampType,
        'UUID'     => Taro::Types::Scalar::UUIDv4Type,
        # rubocop:enable Layout/HashAlignment - buggy cop
      }.freeze
    end

    def raise_cast_error(arg)
      raise Taro::ArgumentError, <<~MSG
        Unsupported type: #{arg.inspect}. Must inherit from a type class
        or be one of #{shortcuts.keys.map(&:inspect).join(', ')}.
      MSG
    end
  end
end
