describe Taro::Types::Shared::DerivedTypes do
  it 'raises an error if the deriving method is already in use' do
    expect do
      Taro::Types::BaseType.define_derived_type(:inspect)
    end.to raise_error(ArgumentError, 'inspect is already in use')
  end

  it 'raises an error if the coercion key is already in use' do
    allow(Taro::Types::Coercion).to receive(:keys).and_return([:blob_of])
    expect do
      Taro::Types::BaseType.define_derived_type(:blob)
    end.to raise_error(ArgumentError, 'blob_of is already in use')
  end
end
