# Abstract base class for Page types (paginated ActiveRecord data).
# Unlike other types, this one should not be manually inherited from,
# but is used indirectly via `page_of: SomeType`.
#
# The gem rails_cursor_pagination must be installed to use this.
#
class Taro::Types::ObjectTypes::PageType < Taro::Types::ObjectType
  extend Taro::Types::Shared::ItemType

  def self.derive_from(from_type)
    super
    field(:page, array_of: from_type.name, null: false)
    field(:page_info, type: 'Taro::Types::ObjectTypes::PageInfoType', null: false)
  end

  def coerce_input
    input_error 'PageTypes cannot be used as input types'
  end

  def self.render(relation, after:, limit: 20, order_by: nil, order: nil)
    result = RailsCursorPagination::Paginator.new(
      relation, limit:, order_by:, order:, after:
    ).fetch

    result[:page].map! { |el| el.fetch(:data) }

    super(result)
  end

  def self.default_openapi_name
    "#{item_type.openapi_name}_Page"
  end

  define_derived_type :page, 'Taro::Types::ObjectTypes::PageType'
end
