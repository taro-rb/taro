## [Unreleased]

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
