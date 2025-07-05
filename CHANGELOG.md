# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2024-01-15

### Added
- Initial release of Gleam Supabase client
- Support for both JavaScript and Erlang targets
- Type-safe query builder pattern
- Basic CRUD operations (select, insert, update, delete)
- Advanced filtering operations:
  - `eq` - Equals
  - `not_eq` - Not equals
  - `gt` - Greater than
  - `lt` - Less than
  - `gte` - Greater than or equal
  - `lte` - Less than or equal
  - `like` - Pattern matching (case sensitive)
  - `ilike` - Pattern matching (case insensitive)
  - `in` - In array of values
  - `or` - OR conditions
- Ordering and pagination:
  - `order` - Sort results
  - `limit` - Limit number of results
  - `range` - Get specific range of results
- Single record queries:
  - `single` - Expect exactly one result
  - `maybe_single` - Expect zero or one result
- RPC function calls
- Custom error types for better error handling
- Comprehensive test suite
- Full documentation with examples

### Security
- Support for secure API key handling
- No hardcoded credentials in code

[Unreleased]: https://github.com/instancer-kirik/gleam-supabase/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/instancer-kirik/gleam-supabase/releases/tag/v0.1.0