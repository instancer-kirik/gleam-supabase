# Supabase Package Tests

This directory contains comprehensive tests for the Supabase Gleam package.

## Test Structure

The test suite is organized into three main files:

### 1. `supabase_test.gleam`
Tests the core functionality of the main supabase module:
- Client creation
- QueryBuilder operations (from, select, insert, update, delete, eq)
- Filter chaining
- Method setting
- RPC functionality
- Complex query building scenarios

### 2. `supabase_ffi_test.gleam`
Tests the FFI wrapper functions that provide a simplified interface:
- Client creation via FFI
- Table querying
- Column selection
- Row insertion
- Filtering operations
- Query execution

### 3. `supabase_integration_test.gleam`
Integration tests that simulate real-world usage scenarios:
- Full query flows (select, insert, update, delete)
- Complex filtering with multiple conditions
- Bulk operations
- Nested JSON data handling
- Edge cases with special characters and empty values
- Multiple operations on the same table

## Running Tests

To run all tests:

```bash
gleam test
```

To run a specific test file:

```bash
gleam test -- supabase_test
```

## Test Coverage

The tests cover:

1. **Basic Operations**
   - Client initialization
   - Table selection
   - CRUD operations (Create, Read, Update, Delete)

2. **Query Building**
   - Column selection
   - Filter conditions
   - Method chaining
   - Complex query composition

3. **Data Handling**
   - Simple JSON objects
   - Nested JSON structures
   - Arrays and complex data types
   - Special characters and edge cases

4. **Error Handling**
   - HTTP request errors (currently expected as HTTP client is not implemented)
   - API errors
   - Decode errors

## Notes

- The HTTP client is not currently implemented for the Erlang target, so `execute()` calls will return `HttpRequestError`.
- RPC functionality returns mock data for testing purposes.
- Tests focus on verifying correct query building and data structure handling.

## Future Enhancements

When the HTTP client is implemented, these tests can be enhanced to:
- Include actual HTTP response mocking
- Test response parsing and error handling
- Add performance benchmarks
- Include authentication flow tests