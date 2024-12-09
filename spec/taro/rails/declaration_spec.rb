describe Taro::Rails::Declaration do
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
  end

  describe '#routes=' do
    it 'raises for invalid args' do
      expect { subject.routes = :route_set }.to raise_error(Taro::ArgumentError)
    end
  end

  require 'action_controller'

  describe '#parse_params' do
    before do
      stub_const('UserInputType', Class.new(T::InputType) do
        field :name, type: 'String', null: false
      end)
      subject.add_param :user, type: 'UserInputType', null: true
    end

    it 'coerces the params' do
      params = ActionController::Parameters.new(user: { name: 'Alice' })
      expect { subject.parse_params(params) }.not_to raise_error
    end

    it 'raises for invalid params' do
      params = ActionController::Parameters.new(user: { name: nil })
      expect do
        subject.parse_params(params)
      end.to raise_error(Taro::InputError, /NilClass is not valid as String/)
    end
  end
end
