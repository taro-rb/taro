module Taro::Types::Coercion
  KEYS = %i[type array_of page_of].freeze

  class << self
    def call(arg)
      validate_hash(arg)
      from_hash(arg)
    end

    private

    def validate_hash(arg)
      arg.is_a?(Hash) || raise(Taro::ArgumentError, <<~MSG)
        Type coercion argument must be a Hash, got: #{arg.inspect} (#{arg.class})
      MSG

      types = arg.slice(*KEYS)
      types.size == 1 || raise(Taro::ArgumentError, <<~MSG)
        Exactly one of type, array_of, or page_of must be given, got: #{types}
      MSG
    end

    def from_hash(hash)
      if hash[:type]
        from_string(hash[:type])
      elsif (inner_type = hash[:array_of])
        from_string(inner_type).array
      elsif (inner_type = hash[:page_of])
        from_string(inner_type).page
      else
        raise NotImplementedError, 'Unsupported type coercion'
      end
    end

    def from_string(arg)
      shortcuts[arg] || from_class(Object.const_get(arg.to_s))
    rescue NameError
      raise Taro::ArgumentError, <<~MSG
        Unsupported type: #{arg}. It should be a type-class name
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
        'Float'     => Taro::Types::Scalar::FloatType,
        'FreeForm'  => Taro::Types::ObjectTypes::FreeFormType,
        'Integer'   => Taro::Types::Scalar::IntegerType,
        'String'    => Taro::Types::Scalar::StringType,
        'Timestamp' => Taro::Types::Scalar::TimestampType,
        'UUID'      => Taro::Types::Scalar::UUIDv4Type,
        # rubocop:enable Layout/HashAlignment - buggy cop
      }.freeze
    end
  end
end
