# Abstract base class for renderable types with fields.
class Taro::Types::ObjectType < Taro::Types::BaseType
  require_relative "shared"
  extend Taro::Types::Shared::Fields
  include Taro::Types::Shared::CustomFieldResolvers
  include Taro::Types::Shared::ObjectCoercion

  self.openapi_type = :object
  self.response_types = [Hash]
  self.input_types = [Hash]

  def self.inherited(subclass)
    subclass.instance_variable_set(:@response_types, [Hash])
    subclass.instance_variable_set(:@input_types, [Hash])
    super
  end
end

module Taro::Types::ObjectTypes
  Dir[File.join(__dir__, 'object_types', '**', '*.rb')].each { |f| require f }
end
