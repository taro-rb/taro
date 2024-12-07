describe Taro::Rails::Declaration do
  describe '#initialize' do
    it 'adds common returns defined for the given class' do
      klass = Class.new
      Taro::CommonReturns.define(klass, code: 200, type: 'String')
      expect(described_class.new(klass).returns).to eq(200 => S::StringType)
      expect(described_class.new(nil).returns).to eq({})
    end
  end

  describe '#add_info=' do
    it 'sets the summary attribute' do
      subject.add_info 'My text'
      expect(subject.summary).to eq('My text')
    end

    it 'can add a description' do
      subject.add_info('...', desc: 'My long text')
      expect(subject.desc).to eq('My long text')
    end

    it 'can add tags' do
      subject.add_info('...', tags: ['My tag'])
      expect(subject.tags).to eq(['My tag'])
    end

    it 'can add single tags' do
      subject.add_info('...', tags: 'My tag')
      expect(subject.tags).to eq(['My tag'])
    end

    it 'raises for invalid args' do
      expect { subject.add_info(42) }.to raise_error(Taro::ArgumentError)
    end
  end

  describe '#add_param' do
    it 'adds the param to the params input type' do
      subject.add_param :foo, type: 'String', null: false
      field = subject.params.fields[:foo]
      expect(field.type).to eq(S::StringType)
      expect(field.null).to eq(false)
    end

    it 'adds the param for derived types' do
      subject.add_param :foo, array_of: 'String', null: false
      expect(subject.params.fields[:foo].type).to eq(S::StringType.array)
    end

    it 'uses the relaxed IntegerParamType for Integer params' do
      subject.add_param :foo, type: 'Integer', null: false
      expect(subject.params.fields[:foo].type).to eq(S::IntegerParamType)
    end

    it 'raises for inexistent types (upon evaluation)' do
      expect do
        subject.add_param :foo, type: 'XType', null: false
        subject.params.fields
      end.to raise_error(Taro::ArgumentError)
    end
  end

  describe '#add_return' do
    it 'sets the returns attribute' do
      subject.add_return type: 'String', code: :ok
      expect(subject.returns).to eq(200 => S::StringType)
    end

    it 'sets the returns attribute for derived types' do
      subject.add_return code: :ok, array_of: 'String'
      expect(subject.returns).to eq(200 => S::StringType.array)
    end

    it 'merges further returns attributes' do
      subject.add_return code: :ok, type: 'String'
      subject.add_return code: :not_found, type: 'Float'
      expect(subject.returns).to eq(
        200 => S::StringType,
        404 => S::FloatType,
      )
    end

    it 'does not auto-load the return type' do
      subject.add_return code: :ok, type: 'NonExistingType'
      expect { subject.returns }
        .to raise_error(Taro::ArgumentError, /No such type: NonExistingType/)
    end

    it 'sets the returns attribute with status numbers' do
      subject.add_return code: 200, type: 'String'
      expect(subject.returns).to eq(200 => S::StringType)
    end

    it 'can add nested returns' do
      subject.add_return :foo, type: 'String', code: :ok, null: true
      expect(subject.returns[200].fields[:foo].type).to eq(S::StringType)
    end

    it 'raises for bad status' do
      expect do
        subject.add_return type: 'String', code: 999
      end.to raise_error(Taro::ArgumentError, /status/)
    end

    it 'raises for top-level null' do
      expect do
        subject.add_return code: 200, type: 'String', null: true
      end.to raise_error(Taro::ArgumentError, /null/)
    end

    it 'raises for unsupported options' do
      expect do
        subject.add_return code: 200, type: 'String', foobar: true
      end.to raise_error(Taro::ArgumentError, /foobar/)
    end

    it 'raises for double declarations' do
      expect do
        subject.add_return code: 200, type: 'String'
        subject.add_return code: 200, type: 'String'
      end.to raise_error(Taro::ArgumentError, /already declared/)
    end
  end

  describe '#routes' do
    it 'calls the RouteFinder' do
      allow(Taro::Rails::RouteFinder).to receive(:call).and_return(:some_routes)
      expect(subject.routes).to eq(:some_routes)
    end
  end
end
