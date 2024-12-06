# Abstract base class for scalar types, i.e. types without fields.
class Taro::Types::ScalarType < Taro::Types::BaseType
  include Taro::Types::Shared::Pattern
end

module Taro::Types::Scalar
  Dir[File.join(__dir__, 'scalar', '**', '*.rb')].each { |f| require_relative f }
end
