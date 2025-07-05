# Supabase Gleam Package Release Notes

## Version 0.1.0 (Pre-release)

### Overview
This is the initial pre-release of the Supabase client library for Gleam. This package provides a type-safe interface for interacting with Supabase databases from Gleam applications.

### Features

#### Core Functionality
- **Client Creation**: Initialize Supabase clients with host URL and API key
- **Query Builder**: Fluent API for building database queries
  - `from()`: Select a table
  - `select()`: Choose columns to retrieve
  - `insert()`: Add new records
  - `update()`: Modify existing records
  - `delete()`: Remove records
  - `eq()`: Add equality filters
- **RPC Support**: Call stored procedures and functions
- **Type Safety**: Full Gleam type system integration

#### Architecture
- **Multi-target Design**: Structured for both JavaScript and Erlang targets
- **FFI Module**: Simplified wrapper functions for common operations
- **Error Handling**: Comprehensive error types for different failure scenarios
  - `HttpRequestError`
  - `ApiError`
  - `DecodeError`
  - `InvalidUrl`
  - `UnsupportedOperation`

### Current Limitations
- **HTTP Client**: The Erlang target HTTP client is not yet implemented
- **Filters**: Currently only supports `eq` (equality) filters
- **Auth**: No authentication flow integration yet
- **Realtime**: No realtime subscriptions support
- **Storage**: No file storage API integration

### Testing
The package includes comprehensive test coverage:
- **Unit Tests**: Core functionality and query building
- **Integration Tests**: Real-world usage scenarios
- **FFI Tests**: Wrapper function behavior
- **Edge Cases**: Special characters, empty values, complex JSON structures

Total: 49 tests, all passing

### Dependencies
- `gleam_stdlib`: 0.60.0
- `gleam_http`: ~> 4.0.0
- `gleam_httpc`: ~> 4.1.0
- `gleam_json`: ~> 3.0.2
- `gleam_javascript`: ~> 1.0

### Usage Example
```gleam
import supabase
import gleam/json

pub fn main() {
  let client = supabase.create("https://your-project.supabase.co", "your-api-key")
  
  // Insert a record
  let user_data = json.object([
    #("name", json.string("Alice")),
    #("email", json.string("alice@example.com")),
  ])
  
  let result = 
    client
    |> supabase.from("users")
    |> supabase.insert(user_data)
    |> supabase.select("id, name, email")
    |> supabase.execute()
  
  // Query with filters
  let active_users = 
    client
    |> supabase.from("users")
    |> supabase.select("id, name, last_login")
    |> supabase.eq("status", "active")
    |> supabase.execute()
}
```

### Roadmap for v1.0.0
1. **HTTP Client Implementation**: Complete Erlang target HTTP support
2. **Extended Filters**: Add support for:
   - `neq` (not equal)
   - `gt`, `gte`, `lt`, `lte` (comparisons)
   - `like`, `ilike` (pattern matching)
   - `in` (value in list)
   - `is` (null checks)
3. **Authentication**: Integration with Supabase Auth
4. **Realtime**: WebSocket support for live queries
5. **Storage**: File upload/download capabilities
6. **Batch Operations**: Bulk inserts and updates
7. **Transactions**: ACID transaction support
8. **Response Parsing**: Proper typed response decoding

### Breaking Changes Expected
As this is a pre-release version, the API may change significantly before v1.0.0. Expected changes include:
- Response type will change from `Dynamic` to properly typed results
- Error types may be expanded
- Filter API might be redesigned for better composability
- Authentication will be integrated into the client

### Contributing
The package is open for contributions. Key areas where help is needed:
- HTTP client implementation for Erlang
- Additional filter operations
- Documentation improvements
- Example applications

### Installation
Add to your `gleam.toml`:
```toml
[dependencies]
supabase = "~> 0.1.0"
```

### License
This package is released under the same license as the main project.

### Acknowledgments
- Built with Gleam's excellent type system and tooling
- Inspired by Supabase's JavaScript and other language clients
- Thanks to the Gleam community for guidance and support