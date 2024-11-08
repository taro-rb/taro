describe Taro::Rails::Definition do
  describe '#api=' do
    it 'sets the api attribute' do
      subject.api = 'My description'
      expect(subject.api).to eq('My description')
    end

    it 'raises for invalid args' do
      expect { subject.api = 42 }.to raise_error(Taro::ArgumentError)
    end
  end

  describe '#accepts=' do
    it 'sets the accepts attribute' do
      subject.accepts = 'String'
      expect(subject.accepts).to eq(S::StringType)
    end

    it 'sets the accepts attribute for derived types' do
      subject.accepts = { array_of: 'String' }
      expect(subject.accepts).to eq(T::ListType.for(S::StringType))
    end

    it 'raises for inexistent types' do
      expect { subject.accepts = 'XType' }.to raise_error(Taro::ArgumentError)
    end
  end

  describe '#returns=' do
    it 'sets the returns attribute' do
      subject.returns = { ok: 'String' }
      expect(subject.returns).to eq(200 => S::StringType)
    end

    it 'sets the returns attribute for derived types' do
      subject.returns = { ok: { array_of: 'String' } }
      expect(subject.returns).to eq(200 => T::ListType.for(S::StringType))
    end

    it 'merges further returns attributes' do
      subject.returns = { ok: 'String' }
      subject.returns = { not_found: 'Float' }
      expect(subject.returns).to eq(
        200 => S::StringType,
        404 => S::FloatType,
      )
    end

    it 'sets the returns attribute with status numbers' do
      subject.returns = { 200 => 'String' }
      expect(subject.returns).to eq(200 => S::StringType)
    end

    it 'raises for bad status' do
      expect do
        subject.returns = { 999 => 'String' }
      end.to raise_error(Taro::Error, /status/)
    end
  end

  describe '#routes=' do
    it 'raises for invalid args' do
      expect { subject.routes = :route_set }.to raise_error(Taro::ArgumentError)
    end
  end

  describe '#openapi_paths' do
    it 'returns the paths of the routes in an openapi compatible format' do
      subject.routes = [mock_user_route]
      expect(subject.openapi_paths).to eq(['/users/{id}'])
    end
  end

  require 'action_controller'

  describe '#parse_params' do
    xit 'coerces the params, expecting nested data by default' do
      stub_const('UserInputType', Class.new(T::InputType) do
        field :name, type: 'String', null: false
      end)
      definition = described_class.new(accepts: 'UserInputType')
      params = ActionController::Parameters.new(user: { name: 'Alice' })
      expect { definition.parse_params(params) }.not_to raise_error
    end

    it 'coerces the params without nesting' do
      orig = Taro.config.input_nesting
      Taro.config.input_nesting = false

      stub_const('UserInputType', Class.new(T::InputType) do
        field :name, type: 'String', null: false
      end)
      definition = described_class.new(accepts: 'UserInputType')
      params = ActionController::Parameters.new(name: 'Alice')
      expect { definition.parse_params(params) }.not_to raise_error
    ensure
      Taro.config.input_nesting = orig
    end
  end
end
