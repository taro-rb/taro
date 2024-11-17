module Taro::Types::Coercion
  class << self
    def call(arg)
      validate_hash(arg)
      from_hash(arg)
    end

    # Coercion keys can be expanded by the DerivedTypes module.
    def keys
      @keys ||= %i[type]
    end

    def derived_suffix
      '_of'
    end

    private

    def validate_hash(arg)
      arg.is_a?(Hash) || raise(Taro::ArgumentError, <<~MSG)
        Type coercion argument must be a Hash, got: #{arg.class}
      MSG

      types = arg.slice(*keys)
      types.size == 1 || raise(Taro::ArgumentError, <<~MSG)
        Exactly one of #{keys.join(', ')} must be given, got: #{types}
      MSG
    end

    def from_hash(hash)
      keys.each do |key|
        next unless (value = hash[key])

        # e.g. `returns type: 'MyType'` -> MyType
        return from_string(value) if key == :type

        # DerivedTypes
        # e.g. `returns array_of: 'MyType'` -> MyType.array
        return from_string(value).send(key.to_s.chomp(derived_suffix))
      end

      raise NotImplementedError, "Unsupported type coercion #{hash}"
    end

    def from_string(arg)
      shortcuts[arg] || from_class(Object.const_get(arg.to_s))
    rescue NameError
      raise Taro::ArgumentError, <<~MSG
        No such type: #{arg}. It should be a type-class name
        or one of #{shortcuts.keys.map(&:inspect).join(', ')}.
      MSG
    end

    def from_class(arg)
      arg < Taro::Types::BaseType || raise(Taro::ArgumentError, <<~MSG)
        Unsupported type: #{arg}. It should be a subclass of Taro::Types::BaseType.
      MSG

      arg
    end

    # Map some Ruby class names and other shortcuts to built-in types
    # to support e.g. `returns 'String'`, or `field :foo, type: 'Boolean'` etc.
    require 'date'
    def shortcuts
      @shortcuts ||= {
        # rubocop:disable Layout/HashAlignment - buggy cop
        'Boolean'   => Taro::Types::Scalar::BooleanType,
        'Date'      => Taro::Types::Scalar::ISO8601DateType,
        'DateTime'  => Taro::Types::Scalar::ISO8601DateTimeType,
        'Float'     => Taro::Types::Scalar::FloatType,
        'FreeForm'  => Taro::Types::ObjectTypes::FreeFormType,
        'Integer'   => Taro::Types::Scalar::IntegerType,
        'NoContent' => Taro::Types::ObjectTypes::NoContentType,
        'String'    => Taro::Types::Scalar::StringType,
        'Time'      => Taro::Types::Scalar::ISO8601DateTimeType,
        'Timestamp' => Taro::Types::Scalar::TimestampType,
        'UUID'      => Taro::Types::Scalar::UUIDv4Type,
        # rubocop:enable Layout/HashAlignment - buggy cop
      }.freeze
    end
  end
end
