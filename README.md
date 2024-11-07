# Taro - Typed Api using Ruby Objects

This library provides an object-based type system for RESTful Ruby APIs, with built-in parameter parsing, response rendering, and OpenAPI schema export.

Inspired by `apipie-rails` and `graphql-ruby`.

## ⚠️ This is a work in progress - TODO:

- maybe make nesting an optional thing to set manually on each type?
  - fail openapi generation if not set or not unique across types?
- additionalProperties, FreeFormType
- OpenAPI export (e.g. `#to_openapi` methods for types)
- openapi metadata via Taro.config, e.g. title
- maybe later: apidoc rendering based on export (rails engine?)
- maybe change controller DSL to avoid conflict with apipie?
- [query logs metadata](https://github.com/rmosolgo/graphql-ruby/blob/dcaaed1cea47394fad61fceadf291ff3cb5f2932/lib/generators/graphql/install_generator.rb#L48-L52)
- rspec matchers for testing?
- examples https://swagger.io/specification/#example-object
- `deprecation`
- move coercion error out of Field, handle in ResponseValidator
- gemspec
- more docs
- consider rename: ObjectType > TaroObjectType, its annoying to inherit from Taro::ObjectType, but its non-optional since ObjectType alone is too generic
- another alternative: include Taro::ObjectType might be more descriptive
- rubocop does not like this: https://docs.rubocop.org/rubocop/cops_style.html#stylehashaslastarrayitem
- list type holds a hash of all items, should be an array
- controller dsl should take type names as strings instead of raw types

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
class BikesController < ApplicationController
  api     'Update a bike' # optional description
  accepts BikeInputType   # accepted params
  returns ok: BikeType,   # return types by status code
          unprocessable_content: MyErrorType
  def update
    if bike.update(@api_params) # automatically parsed params
      render json: BikeType.render(bike), status: :ok
    else
      render json: MyErrorType.render(bike.errors), status: :unprocessable_entity
    end
  end
end

# ObjectTypes are used to define, render, and validate responses.
class BikeType < ObjectType
  # Optional type description (for docs and OpenAPI export)
  self.description = 'A bike and all relevant information about it'

  # Field nullability must be set, description is optional
  field(:brand)     { [String,  null: true, description: 'The brand name'] }

  # Fields can reference other types and arrays of values
  field(:users)     { [[UserType], null: false] }

  # Pagination is built-in for big lists
  field(:parts)     { [PartType.page, null: false] }

  # Custom methods can be chosen to resolve fields
  field(:has_brand) { [Boolean, null: true, method: :brand?] }

  # Field resolvers can also be implemented or overridden on the type
  field(:info)      { [String,  null: true] }

  def info
    "A bike named #{object.name} with #{object.wheels} wheels."
  end
end

# The usage of dedicated InputTypes is optional.
# Object types can also be used to define accepted parameters –
# or parts of them.
class BikeInputType < InputType
  field(:brand)  { [String, null: false, description: 'The brand name'] }
  field(:wheels) { [String, null: true, default: 2] }
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
