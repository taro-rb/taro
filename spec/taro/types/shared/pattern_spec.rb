describe Taro::Types::Shared::Pattern do
  it 'can be set on string types, setting openapi_pattern' do
    example = Class.new(S::StringType)
    example.pattern = /foo/
    expect(example.openapi_pattern).to eq('foo')
  end

  it 'can not be set on non-string types' do
    example = Class.new(S::IntegerType)
    expect { example.pattern = /foo/ }
      .to raise_error(Taro::RuntimeError, 'pattern requires openapi_type :string')
  end

  describe '::validate' do
    it 'allows simple regexp' do
      expect(described_class.validate(/foo/)).to eq(/foo/)
    end

    it 'allows anchored regexp' do
      expect(described_class.validate(/\Afoo\z/)).to eq(/\Afoo\z/)
    end

    it 'disallows empty regexp' do
      expect { described_class.validate(//) }
        .to raise_error(Taro::ArgumentError, 'pattern cannot be empty')
    end

    it 'disallows regexp with options' do
      expect { described_class.validate(/x/ix) }
        .to raise_error(Taro::ArgumentError, 'pattern flags (/ix) are not supported')
    end

    it 'disallows advanced regexp' do
      expect { described_class.validate(/foo\Kbar/) }.to raise_error(
        Taro::ArgumentError,
        'pattern uses non-JS syntax \K (a Ruby-specific escape) at index 3'
      )
    end
  end

  describe '::to_es262' do
    it 'translates ruby anchors and hex escapes for openapi (ECMA262)' do
      expect(described_class.to_es262(/\Afoo\hbar\z/)).to eq('^foo[0-9a-fA-F]bar$')
    end

    it 'accepts and retains escaped "advanced" regexp' do
      expect(described_class.to_es262(/foo\\Kbar/)).to eq('foo\\\\Kbar')
    end

    it 'translates multiple backslashes correctly' do
      expect(described_class.to_es262(/foo\\\z/)).to eq('foo\\\\$')
    end
  end
end
