# This is an expanded `PageType` that adds a `total_count` field
# to show the total number of records in the paginated relation.
# It is not recommended for very large relations where counting might be slow.
#
# Usage:
# - `returns code: :ok, page_with_total_count_of: 'UserType'`
# - `UserType.page_with_total_count.render(User.all, after: params[:cursor])`
#
# The gem rails_cursor_pagination must be installed to use this.
#
class Taro::Types::ObjectTypes::PageWithTotalCountType < Taro::Types::ObjectTypes::PageType
  def self.derive_from(from_type)
    super
    field(:total_count, type: 'Integer', null: false)
  end

  def self.paginate(relation, **)
    super.merge(total_count: relation.count)
  end

  def self.default_openapi_name
    "#{item_type.openapi_name}_PageWithTotalCount"
  end

  define_derived_type :page_with_total_count, 'Taro::Types::ObjectTypes::PageWithTotalCountType'
end
