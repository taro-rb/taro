describe Taro::Rails::Definition do
  describe '#accepts=' do
    it 'sets the accepts attribute' do
      definition = described_class.new
      definition.accepts = String
      expect(definition.accepts).to eq(S::StringType)
    end
  end

  describe '#returns=' do
    it 'sets the returns attribute' do
      definition = described_class.new
      definition.returns = { ok: String }
      expect(definition.returns).to eq(200 => S::StringType)
    end

    it 'merges further returns attributes' do
      definition = described_class.new
      definition.returns = { ok: String }
      definition.returns = { not_found: Float }
      expect(definition.returns).to eq(
        200 => S::StringType,
        404 => S::FloatType,
      )
    end

    it 'sets the returns attribute with status numbers' do
      definition = described_class.new
      definition.returns = { 200 => String }
      expect(definition.returns).to eq(200 => S::StringType)
    end

    it 'raises for bad status' do
      definition = described_class.new
      expect do
        definition.returns = { 999 => String }
      end.to raise_error(Taro::Error, /status/)
    end
  end

  describe '#openapi_paths' do
    it 'returns the paths of the routes in an openapi compatible format' do
      definition = described_class.new
      definition.routes = [mock_user_route]
      expect(definition.openapi_paths).to eq(['/users/{id}'])
    end
  end

  require 'action_controller'

  describe '#parse_params' do
    it 'coerces the params, expecting nested data by default' do
      input_type = Class.new(T::InputType)
      input_type.define_singleton_method(:name) { 'UserInputType' }
      input_type.field :name, type: 'String', null: false
      definition = described_class.new(accepts: input_type)
      params = ActionController::Parameters.new(user: { name: 'Alice' })
      coerced = definition.parse_params(params)
      expect(coerced).to eq(name: 'Alice')
    end

    it 'coerces the params without nesting' do
      orig = Taro.config.input_nesting
      Taro.config.input_nesting = false

      input_type = Class.new(T::InputType)
      input_type.define_singleton_method(:name) { 'UserInputType' }
      input_type.field :name, type: 'String', null: false
      definition = described_class.new(accepts: input_type)
      params = ActionController::Parameters.new(name: 'Alice')
      coerced = definition.parse_params(params)
      expect(coerced).to eq(name: 'Alice')
    ensure
      Taro.config.input_nesting = orig
    end
  end
end
