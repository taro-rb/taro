module Taro::Types::CoerceToType
  class << self
    def call(arg)
      if arg.instance_of?(Array)
        type(arg.first).list
      else
        type(arg)
      end
    end

    private

    def type(arg)
      return arg if arg < Taro::Types::BaseType

      shortcuts[arg] || raise_cast_error(arg)
    end

    # Map some Ruby classes to built-in types to support e.g.
    # `returns String`, or `field { [Integer, ...] }`, etc.
    require 'date'
    def shortcuts
      @shortcuts ||= {
        # rubocop:disable Layout/HashAlignment - buggy cop
        ::Date     => Taro::Types::Scalar::TimestampType,
        ::DateTime => Taro::Types::Scalar::TimestampType,
        ::Float    => Taro::Types::Scalar::FloatType,
        ::Integer  => Taro::Types::Scalar::IntegerType,
        ::String   => Taro::Types::Scalar::StringType,
        ::Time     => Taro::Types::Scalar::TimestampType,
        # rubocop:enable Layout/HashAlignment - buggy cop
      }.freeze
    end

    def raise_cast_error(arg)
      raise Taro::ArgumentError, <<~MSG
        Unsupported type: #{arg.inspect}. Must inherit from a type class
        or be one of #{shortcuts.keys.join(', ')}.
      MSG
    end
  end
end
