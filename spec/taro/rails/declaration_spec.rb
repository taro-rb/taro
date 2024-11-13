describe Taro::Rails::Declaration do
  describe '#add_info=' do
    it 'sets the summary attribute' do
      subject.add_info 'My description'
      expect(subject.summary).to eq('My description')
    end

    it 'can add description' do
      subject.add_info('...', description: 'My long description')
      expect(subject.description).to eq('My long description')
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
      expect(subject.params.fields[:foo].type).to eq(T::ListType.for(S::StringType))
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
      expect(subject.returns).to eq(200 => T::ListType.for(S::StringType))
    end

    it 'merges further returns attributes' do
      subject.add_return code: :ok, type: 'String'
      subject.add_return code: :not_found, type: 'Float'
      expect(subject.returns).to eq(
        200 => S::StringType,
        404 => S::FloatType,
      )
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
      end.to raise_error(Taro::Error, /status/)
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
      end.to raise_error(Taro::InputError, /nil.*must be a String/)
    end
  end
end
