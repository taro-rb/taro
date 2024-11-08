module Taro::Types::CoerceToType
  class << self
    def from_string_or_hash!(arg)
      from_hash(arg) || from_string(arg) || raise(Taro::ArgumentError, <<~MSG)
        Unsupported type: #{arg.inspect}. Must be a Hash containining a type name,
        e.g. { type: "MyType" }, or be the name of a type class,
        e.g. "MyType", #{shortcuts.keys.map(&:inspect).join(', ')}.
      MSG
    end

    def from_string!(arg)
      from_string(arg) || raise(Taro::ArgumentError, <<~MSG)
        Unsupported type: #{arg.inspect}. Must be the name of a type class,
        e.g. "MyType", #{shortcuts.keys.map(&:inspect).join(', ')}.
      MSG
    end

    def from_hash!(arg)
      from_hash(arg) || raise(Taro::ArgumentError, <<~MSG)
        Unsupported type: #{arg.inspect}. Must be a hash containing the name
        of a type class, e.g. { type: "MyType" }.
      MSG
    end

    private

    def from_class(arg)
      arg if arg.is_a?(Class) && arg < Taro::Types::BaseType
    end

    def from_hash(arg)
      return unless arg.is_a?(Hash)

      if arg[:type]
        from_string(arg[:type])
      elsif (inner_type = arg[:array_of])
        Taro::Types::ListType.for(from_string(inner_type))
      elsif (inner_type = arg[:page_of])
        Taro::Types::ObjectTypes::PageType.for(from_string(inner_type))
      end
    end

    def from_string(arg)
      arg.is_a?(String) && (shortcuts[arg] || from_class(Object.const_get(arg)))
    rescue NameError
      nil
    end

    # Map some Ruby class names and other shortcuts to built-in types
    # to support e.g. `returns 'String'`, or `field :foo, type: 'Boolean'` etc.
    require 'date'
    def shortcuts
      @shortcuts ||= {
        # rubocop:disable Layout/HashAlignment - buggy cop
        'Boolean'  => Taro::Types::Scalar::BooleanType,
        'Date'     => Taro::Types::Scalar::DateType,
        'DateTime' => Taro::Types::Scalar::TimestampType,
        'Float'    => Taro::Types::Scalar::FloatType,
        'Integer'  => Taro::Types::Scalar::IntegerType,
        'String'   => Taro::Types::Scalar::StringType,
        'Time'     => Taro::Types::Scalar::TimestampType,
        'UUID'     => Taro::Types::Scalar::UUIDv4Type,
        # rubocop:enable Layout/HashAlignment - buggy cop
      }.freeze
    end
  end
end
