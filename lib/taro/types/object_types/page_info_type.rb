class Taro::Types::ObjectTypes::PageInfoType < Taro::Types::ObjectType
  field :has_previous_page, type: 'Boolean', null: false, description: 'Whether there is a previous page of results'
  field :has_next_page, type: 'Boolean', null: false, description: 'Whether there is another page of results'
  field :start_cursor, type: 'String', null: true, description: 'The first cursor in the current page of results (null if zero results)'
  field :end_cursor, type: 'String', null: true, description: 'The last cursor in the current page of results (null if zero results)'
end
