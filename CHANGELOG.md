## [Unreleased]

### Added

- Improved error messages
- Option to define custom derived types
- Option to use custom keys in paginated content
- Option to deprecate individual fields and params

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

## [1.1.0] - 2024-11-16

- Response validation refined
- Bugfix for openapi export

## [1.0.0] - 2024-11-14

- Initial release
