# This derives a name from the type class. That name is used:
# (1) when parsing input if Config.input_nesting is enabled
# (2) when generating a response if Config.response_nesting is enabled
# (3) in the OpenAPI export
# Subclasses may override `default_nesting` but shouldn't override `nesting`.
module Taro::Types::Shared::Nesting
  def nesting
    if @custom_nesting.nil?
      @default_nesting ||= default_nesting&.to_sym
    elsif @custom_nesting.respond_to?(:call)
      @custom_nesting.call(self).to_sym
    else
      @custom_nesting
    end
  end

  def default_nesting
    # e.g. Vehicles::BigBikeType => 'vehicles__big_bike'
    name
      .chomp('Type')
      .gsub('::', '__')
      .gsub(/(?<=\p{lower})(?=\p{upper})/, '_')
      .downcase
  end

  def nesting=(arg)
    if arg.respond_to?(:call)
      @custom_nesting = arg
    else
      @custom_nesting = arg&.to_sym
    end
  end

  def inherited(subclass)
    subclass.instance_variable_set(:@custom_nesting, @custom_nesting.dup)
    super
  end
end
