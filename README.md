# Taro - Typed Api using Ruby Objects

This library provides an object-based type system for RESTful Ruby APIs, with built-in parameter parsing, response rendering, and OpenAPI schema export.

Inspired by `apipie-rails` and `graphql-ruby`.

## ⚠️ This is a work in progress - TODO:

- route inference
  - apipie/application.rb:28-70
  - apipie/routes_formatter.rb
- array support
- additionalProperties
- OpenAPI export (e.g. `#to_openapi` methods for types)
- maybe later: apidoc rendering based on export (rails engine?)
- pagination support (with rails-cursor-pagination? or maybe do this later?)
- [query logs metadata](https://github.com/rmosolgo/graphql-ruby/blob/dcaaed1cea47394fad61fceadf291ff3cb5f2932/lib/generators/graphql/install_generator.rb#L48-L52)
- add a NoContentType?
- rspec matchers for testing?
- benchmark for validation of a big response
- examples https://swagger.io/specification/#example-object
- more docs

## Installation

```bash
bundle add taro
```

Then, if using rails, generate type files to inherit from:

```bash
rails generate taro:install [ --dir app/my_types_dir ]
```

## Usage

Example:

```ruby
class CarsController < ApplicationController
  api     'Update a car' # optional description
  accepts CarInputType   # accepted params
  returns ok: CarType,   # return types by status code
          unprocessable_content: MyErrorType
  def update
    if car.update(@api_params) # automatically parsed params
      render json: CarType.render(car), status: :ok
    else
      render json: MyErrorType.render(car.errors), status: :unprocessable_entity
    end
  end
end

# ObjectTypes are used to define, render, and validate responses.
class CarType < ObjectType
  # Optional type description (for docs and OpenAPI export)
  self.description = 'A car and all relevant information about it'

  field(:name)     { [String,  null: true, description: 'The name'] }
  field(:has_name) { [Boolean, null: true, method: :name?] }
  field(:info)     { [String,  null: true] }

  # Field resolvers can be implemented or overridden on the type
  def info
    "A car named #{object.name} with #{object.wheels} wheels."
  end
end

# The usage of dedicated InputTypes is optional.
# Object types can also be used to define accepted parameters –
# or parts of them.
class CarInputType < InputType
  field(:name)   { [String, null: false, description: 'The name'] }
  field(:wheels) { [String, null: true, default: 4] }
end
```

## Not supported yet

- non-JSON content types
- sum types
- mixed enums
- nullable enums
- format specifications
- min/max values

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/taro.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
