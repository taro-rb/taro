## [Unreleased]

### Added

- error message when incorrectly chaining `with_cache`

## [2.1.0] - 2025-02-21

### Added

- added support for caching on type level and when calling render
  - default cache will be set to Rails.cache in the railtie
  - cache_key can be a string, an array, a hash or a proc

## [2.0.0] - 2024-12-15

### Changed

- rendering undeclared http error codes (except 422) is now allowed
  - this previously raised errors when done in endpoints with other declarations
  - as a result, some errors rendered from `rescue_from` blocks became 500s
- deduplicated response schemas for ad-hoc nested returns in OpenAPI export
  - this only affects nested returns e.g. `returns :x, code: :ok, type: 'YType'`
  - old name: `get_show_ys_200_Response`, new_name: `Y_in_x_Response`
- removed option to render nested returns with string keys
  - e.g. for `returns :foo, [...]`,  `render json: { 'foo' => [...] }` fails now
- removed `Taro::Rails.declarations`, replaced it with `Taro.declarations`

### Added

- added `::common_return` to define common return types
- added support for declaring path & query params as Integer
  - e.g. `param :id, type: 'Integer', required: true` for `/users/1`
  - e.g. `param :page, type: 'Integer', required: true` for `?page=1`
- added parsed/rendered object to validation errors for debugging
- improved validation error messages

### Fixed

- fixed unnecessary `$LOAD_PATH` searches at require time

## [1.4.0] - 2024-11-27

### Added

- added operationId to OpenAPI export

### Fixed

- fixed potential ref name clashes in OpenAPI export
  - e.g. `FooBar::BazController` & `Foo::BarBazController`

## [1.3.0] - 2024-11-25

### Added

- Support for string patterns (on StringType children and in export)

### Fixed

- Fixed OpenAPI export of params with enum (inline & type-based)

## [1.2.0] - 2024-11-18

### Added

- Improved error messages
- Option to define custom derived types
- Option to use custom keys in paginated content
- Option to deprecate individual fields, params, and types

### Fixed

- Fixed nullable enum fields raising for null input
- Fixed auto-loading of return types
- Fixed console spam when inspecting declarations
- Fixed resolver method not being used when rendering a Hash
- Fixed the ErrorsType template
- Many fixes for OpenAPI export
  - Fixed export of parameters for http methods without body
  - Fixed export for PageType
  - Fixed export for arrays of UUIDs, Dates, and Times
  - Fixed export YML keys for namespaced controllers
  - Reference plain types for repeated flat return types
  - Made order of paths, verbs, responses and schemas deterministic

## [1.1.0] - 2024-11-16

### Added

- Response validation refined

### Fixed

- Bugfix for openapi export

## [1.0.0] - 2024-11-14

- Initial release
