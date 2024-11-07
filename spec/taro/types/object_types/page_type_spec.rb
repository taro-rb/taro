describe Taro::Types::ObjectTypes::PageType do
  let(:example) { described_class.for(S::StringType) }
  let(:page_info) do
    { has_previous_page: true, has_next_page: true, start_cursor: 'x', end_cursor: 'y' }
  end

  it 'can not coerce input' do
    expect do
      example.new('foo').coerce_input
    end.to raise_error(Taro::RuntimeError, 'PageTypes cannot be used as input types')
  end

  it 'coerces response data' do
    expect(example.new({ page: [], page_info: }).coerce_response).to eq(page: [], page_info:)
    expect(example.new({ page: [{ data: 'x' }], page_info: }).coerce_response).to eq(page: %w[x], page_info:)
    expect(example.new({ page: [{ data: 42 }], page_info: }).coerce_response).to be_nil
  end

  it 'renders with rails_cursor_pagination' do
    require 'rails_cursor_pagination'

    stub_const('ActiveRecord::Relation', Class.new)
    allow_any_instance_of(RailsCursorPagination::Paginator)
      .to receive(:fetch)
      .and_return(page: [], page_info:)

    example.render(ActiveRecord::Relation.new, after: 'x')
  end

  it 'has a default_nesting for contents without own nesting' do
    expect(example.nesting).to eq :page
  end

  it 'has a default_nesting for complex type content' do
    obj_type = Class.new(T::ObjectType)
    obj_type.define_singleton_method(:name) { 'ObjType' }
    page_type = described_class.for(obj_type)
    expect(page_type.nesting).to eq :obj_page
  end
end
