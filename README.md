# Taro - Typed Api using Ruby Objects

[![Gem Version](https://badge.fury.io/rb/taro.svg)](https://rubygems.org/gems/taro)
[![Build Status](https://github.com/taro-rb/taro/actions/workflows/main.yml/badge.svg)](https://github.com/taro-rb/taro/actions)

This library provides an object-based type system for RESTful Ruby APIs, with built-in parameter parsing, response rendering, and OpenAPI schema export.

It is inspired by [`apipie-rails`](https://github.com/Apipie/apipie-rails) and [`graphql-ruby`](https://github.com/rmosolgo/graphql-ruby).

## Goals

- provide a simple, declarative way to describe API endpoints
- conveniently check request and response data against the declaration
- offer an up-to-date OpenAPI export with minimal configuration

## Installation

```bash
bundle add taro
```

Then, if using rails, generate type files to inherit from:

```bash
bundle exec rails g taro:rails:install [ --dir app/my_types_dir ]
```

## Usage

The core concept of Taro are type classes.

This is how type classes can be used in a Rails controller:

```ruby
class BikesController < ApplicationController
  # This adds an endpoint summary, description, and tags to the docs (all optional)
  api     'Update a bike', desc: 'My longer text', tags: ['Bikes']

  # Params can come from the path, e.g. /bike/:id.
  # Some types, like UUID in this case, are predefined. See below for more types.
  param   :id, type: 'UUID', null: false, desc: 'ID of the bike to update'

  # Params can also come from the query string or request body.
  # This describes a Hash param:
  param   :bike, type: 'BikeInputType', null: false

  # Return types can differ by status code:
  returns code: :ok, type: 'BikeType', desc: 'update success'

  # Return types can also be nested (in this case in an "error" key):
  returns :error, code: :unprocessable_content, type: 'MyErrorType'

  def update
    # Declared params are available as @api_params
    bike = Bike.find(@api_params[:id])
    success = bike.update(@api_params[:bike])

    # Types are also used to render responses.
    if success
      render json: BikeType.render(bike), status: :ok
    else
      render json: { error: MyErrorType.render(bike.errors.first) }, status: :unprocessable_entity
    end
  end

  # Support for arrays and paginated lists is built-in.
  api     'List all bikes'
  returns code: :ok, array_of: 'BikeType', desc: 'list of bikes'
  def index
    render json: BikeType.array.render(Bike.all)
  end
end
```

Notice the multiple roles of types: They are used to describe the structure of API requests and responses, and render the response. Both the input and output of the API are validated against the schema by default (see below).

Here is an example of the `BikeType` from the controller above:

```ruby
class BikeType < ObjectType
  # Optional description of BikeType (for the OpenAPI export)
  self.desc = 'A bike and all relevant information about it'

  # Object types have fields. Each field has a name, its own type,
  # and a `null:` setting to indicate if it can be nil.
  # Providing a description is optional.
  field :brand, type: 'String', null: true, desc: 'The brand name'

  # Fields can reference other types and arrays of values
  field :users, array_of: 'UserType', null: false

  # Pagination is built-in for big lists
  field :parts, page_of: 'PartType', null: false

  # Custom methods can be chosen to resolve fields
  field :has_brand, type: 'Boolean', null: false, method: :brand?

  # Field resolvers can also be implemented or overridden on the type.
  # The object passed in to `BikeType.render` is available as `object`.
  field :fancy_info, type: 'String', null: false
  def fancy_info
    "A bike named #{object.name} with #{object.parts.count} parts."
  end
end
```

### Input and response types

You can use object types for input and output. However, if you want added control, you can also define dedicated input and response types.

Note the use of `BikeInputType` in the `param` declaration above? It could look like so:

```ruby
class BikeInputType < InputType
  field :brand,  type: 'String',  null: true,  desc: 'The brand name'
  field :wheels, type: 'Integer', null: false, default: 2
end
```

A type inheriting from InputType behaves just like an ObjectType when parsing parameters. The only difference is that it can't be used in response declarations.

Likewise, there is a special type for responses, which can't be used in input declarations:

```ruby
class BikeSearchResponseType < ResponseType
  field :bike, type: 'BikeType', null: true, desc: 'The found bike'
  field :search_duration, type: 'Integer', null: false
end
```

In cases where users may edit every attribute that you render, using a single ObjectType for both input and output is more convenient. E.g. `BikeType` could be used for both input and output in the `update` action above – if all its fields should be editable.

### Validation

#### Request validation

Requests are automatically validated to match the declared input schema, unless you disable the automatic parsing of parameters into the `@api_params` hash:

```ruby
Taro.config.parse_params = false
```

#### Response validation

Responses are automatically validated to have used the correct type for rendering, which guarantees that they match the declaration. This means you have to use the types to render complex responses, and manually building a Hash that conforms to the schema will raise an error. Primitive/scalar types are an exception, e.g. you *can* do:

```ruby
returns code: :ok, array_of: 'String', desc: 'Bike names'
def index
  render json: ['Super bike', 'Slow bike']
end
```

An error is also raised if a documented endpoint renders an undocumented status code, e.g.:

```ruby
returns code: :ok, type: 'BikeType'
def create
  render json: BikeType.render(bike), status: :created
  # => undeclared 201 response, raises response validation error
end
```

HTTP error codes, except 422, are an exception. They can be rendered without prior declaration. E.g.:

```ruby
returns code: :ok, type: 'BikeType'
def show
  render json: something, status: :not_found # works
end
```

The reason for this is that Rack and Rails commonly render codes like 400, 404, 500 and various others, but you might not want to have that fact documented on every single endpoint.

However, if you do declare an error code, responses with this code *are* validated:

```ruby
returns code: :not_found, type: 'ExpectedErrorType'
def show
  render json: WrongErrorType.render(foo), status: :not_found
  # => type mismatch, raises response validation error
end
```

Response validation can be disabled:

```ruby
Taro.config.validate_responses = false
```

### Common error declarations

`::common_return` can be used to add a return declaration to all actions in a controller and its subclasses, and all related OpenAPI exports.

```ruby
class AuthenticatedApiBaseController < ApiBaseController
  common_return code: :unauthorized, type: 'MyErrorType', desc: 'Log in first'

  rescue_from 'MyAuthError' do
    render json: MyErrorType.render(something), status: :unauthorized
  end
end
```

### Included type options

The following type names are available by default and can be used as `type:`, `array_of:`, or `page_of:` arguments:

- `'Boolean'` - accepts and renders `true` or `false`
- `'Date'` - accepts and renders a date string in ISO8601 format
- `'DateTime'` - an alias for `'Time'`
- `'Float'`
- `'FreeForm'` - accepts and renders any JSON-serializable object, use with care
- `'Integer'`
- `'NoContent'` - renders an empty object, for use with `status: :no_content`
- `'String'`
- `'Time'` - accepts and renders a time string in ISO8601 format
- `'Timestamp'` - renders a `Time` as unix timestamp integer and turns incoming integers into a `Time`
- `'UUID'` - accepts and renders UUIDs

Also, when using the rails generator, `ErrorsType` and `ErrorDetailsType` are generated as a starting point for unified error presentation. `ErrorsType` can render invalid `ActiveRecord` instances, `ActiveModel::Errors` and other data structures.

### Enums

`EnumType` can be inherited from to define shared enums:

```ruby
class SeverityEnumType < EnumType
  value 'info'
  value 'warning'
  value 'debacle'
end

class ErrorType < ObjectType
  field :severity, type: 'SeverityEnumType', null: false
end
```

Inline enums are also possible. Unlike EnumType classes, these are inlined in the OpenAPI export and not extracted into refs.

```ruby
class ErrorType < ObjectType
  field :severity, type: 'String', enum: %w[info warning debacle], null: false
end
```

## FAQ

### How do I render API docs?

Rendering docs is outside of the scope of this project. You can use the OpenAPI export to generate docs with tools such as RapiDoc, ReDoc, or Swagger UI.

### How do I use context in my types?

Use [ActiveSupport::CurrentAttributes](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html).

```ruby
class BikeType < ObjectType
  field :secret_name, type: 'String', null: true

  def secret_name
    Current.user.superuser? ? object.secret_name : nil
  end
end
```

### How do I migrate from apipie-rails?

First of all, if you don't need a better OpenAPI export, or better support for hashes and arrays, or less repetitive definitions, it might not be worth it.

Please also note the following:

- `taro` currently only supports the latest OpenAPI standard (instead of v2 like `apipie-rails`)
- `taro` does not support arbitrary validations - only those that can be expressed in the OpenAPI schema
- `taro` does not render API docs, as mentioned above

If you want to migrate anyway:

- extract complex param declarations into InputTypes
- extract complex response declarations into ObjectTypes or ResponseTypes
- replace `required: true` with `null: false` and `required: false` with `null: true`

Taro uses some of the same DSL as `apipie`, so for a step-by-step migration, you might want to make `taro` use a different one. This initializer will change the `taro` DSL to `taro_api`, `taro_param`, and `taro_returns` and leave `api`, `param`, and `returns` to `apipie`:

```ruby
# config/initializers/taro.rb
%i[api param returns].each do |m|
  Taro::Rails::DSL.alias_method("taro_#{m}", m) # `taro_api` etc.
  Taro::Rails::DSL.define_method(m) { |*a, **k, &b| super(*a, **k, &b) }
end
```

### How do I keep lengthy API descriptions out of my controller?

```ruby
module BikeUpdateDesc
  extend ActiveSupport::Concern

  included do
    api 'Update a bike', description: 'Long description', tags: ['Bikes']
    # lots of params and returns ...
  end
end

class BikesController < ApplicationController
  include BikeUpdateDesc
  def update # ...
end
```

### Why do I have to use type name strings instead of the type constants?

Why e.g. `field :id, type: 'UUID'` instead of `field :id, type: UUID`?

The purpose of this is to reduce unnecessary autoloading of the whole type dependency tree in dev and test environments.

### Can I define my own derived types like `page_of` or `array_of`?

Yes.

```ruby
# Implement ::derive_from in your custom type.
class PreviewType < Taro::Types::Scalar::StringType
  singleton_class.attr_reader :type_to_preview

  def self.derive_from(other_type)
    self.type_to_preview = other_type
  end

  def coerce_response
    type_to_preview.new(object).coerce_response.to_s.truncate(100)
  end
end

# Make it available in the DSL, e.g. in an initializer.
Taro::Types::BaseType.define_derived_type :preview, 'PreviewType'

# Usage:
class MyController < ApplicationController
  returns code: :ok, preview_of: 'BikeType'
  def show
    render json: BikeType.preview.render(Bike.find(params[:id]))
  end
end
```

## Possible future features

- warning/raising for undeclared input params (currently they are ignored)
- usage without rails is possible but not convenient yet
- rspec matchers for testing
- sum types
- [query logs metadata](https://github.com/rmosolgo/graphql-ruby/blob/dcaaed1cea47394fad61fceadf291ff3cb5f2932/lib/generators/graphql/install_generator.rb#L48-L52)
- various openapi features
  - non-JSON content types (e.g. for file uploads)
  - [examples](https://swagger.io/specification/#example-object)
  - array minItems, maxItems, uniqueItems
  - mixed arrays
  - mixed enums
  - nullable enums
  - string format specifications (e.g. binary, int64, password ...)
  - string minLength and maxLength (substitute: `self.pattern = /\A.{3,5}\z/`)
  - number minimum, exclusiveMinimum, maximum, multipleOf
  - readOnly, writeOnly

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taro-rb/taro.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
