module Taro::Types::Shared::AdditionalProperties
  attr_writer :additional_properties

  def additional_properties?
    !!@additional_properties
  end

  def inherited(subclass)
    super
    subclass.additional_properties = @additional_properties
  end
end
