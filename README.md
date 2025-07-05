# Gleam Supabase Client

A type-safe Supabase client implementation in Gleam that works on both JavaScript and Erlang targets.

## Features

- ✅ Type-safe query builder pattern
- ✅ Support for both JavaScript and Erlang targets
- ✅ Fluent API using Gleam's pipe operator
- ✅ Comprehensive query operations (select, insert, update, delete)
- ✅ Advanced filtering (eq, gt, lt, gte, lte, like, ilike, in, not_eq)
- ✅ Ordering and pagination (order, limit, range)
- ✅ Single record queries (single, maybe_single)
- ✅ RPC function calls
- ✅ Custom error types for better error handling

## Installation

Add to your `gleam.toml`:

```toml
[dependencies]
supabase = { path = "../supabase" }
```

## Usage

### Initialize Client

```gleam
import supabase

let client = supabase.create(
  "https://your-project.supabase.co",
  "your-anon-key"
)
```

### Query Examples

#### Select All Posts

```gleam
let result = 
  client
  |> supabase.from("posts")
  |> supabase.select("*")
  |> supabase.order("date", False)  // descending
  |> supabase.execute()
```

#### Get Single Post by Slug

```gleam
let result = 
  client
  |> supabase.from("posts")
  |> supabase.select("*")
  |> supabase.eq("slug", "my-post-slug")
  |> supabase.single()
  |> supabase.execute()
```

#### Filter by Category with Pagination

```gleam
let result = 
  client
  |> supabase.from("posts")
  |> supabase.select("id, title, slug, excerpt")
  |> supabase.eq("category", "technology")
  |> supabase.order("date", False)
  |> supabase.limit(10)
  |> supabase.range(0, 9)
  |> supabase.execute()
```

#### Search Posts

```gleam
let result = 
  client
  |> supabase.from("posts")
  |> supabase.select("*")
  |> supabase.ilike("title", "%search term%")
  |> supabase.execute()
```

#### Complex Filtering

```gleam
let result = 
  client
  |> supabase.from("posts")
  |> supabase.select("*")
  |> supabase.eq("category", "technology")
  |> supabase.gte("date", "2024-01-01")
  |> supabase.in("status", ["published", "featured"])
  |> supabase.order("date", False)
  |> supabase.limit(20)
  |> supabase.execute()
```

### CRUD Operations

#### Insert

```gleam
let post_data = json.object([
  #("title", json.string("My New Post")),
  #("slug", json.string("my-new-post")),
  #("content", json.string("Post content here")),
  #("category", json.string("technology")),
])

let result = 
  client
  |> supabase.from("posts")
  |> supabase.insert(post_data)
  |> supabase.select("*")  // Return the inserted record
  |> supabase.execute()
```

#### Update

```gleam
let updates = json.object([
  #("title", json.string("Updated Title")),
  #("updated_at", json.string("2024-01-15T10:00:00Z")),
])

let result = 
  client
  |> supabase.from("posts")
  |> supabase.eq("id", "post-id")
  |> supabase.update(updates)
  |> supabase.select("*")  // Return the updated record
  |> supabase.execute()
```

#### Delete

```gleam
let result = 
  client
  |> supabase.from("posts")
  |> supabase.eq("id", "post-id")
  |> supabase.delete()
  |> supabase.execute()
```

### RPC Functions

```gleam
let params = json.object([
  #("user_id", json.string("123")),
  #("limit", json.int(10)),
])

let result = supabase.rpc("get_user_posts", params, client)
```

## Error Handling

The client returns a `Result` type with custom error variants:

```gleam
pub type SupabaseError {
  HttpRequestError(String)
  ApiError(status_code: Int, response_body: String)
  DecodeError(json.DecodeError)
  UnsupportedOperation(String)
  InvalidUrl(String)
}

// Handle errors
case supabase.execute(query) {
  Ok(data) -> // Process data
  Error(supabase.HttpRequestError(msg)) -> // Network error
  Error(supabase.ApiError(code, body)) -> // API error
  Error(supabase.DecodeError(err)) -> // JSON decode error
  Error(_) -> // Other errors
}
```

## Response Handling

Responses are returned as `dynamic.Dynamic` values. You'll need to decode them:

```gleam
import gleam/dynamic

// Define your type
type Post {
  Post(
    id: String,
    title: String,
    slug: String,
    content: String,
  )
}

// Create a decoder
fn decode_post(data: dynamic.Dynamic) -> Result(Post, List(dynamic.DecodeError)) {
  use id <- result.try(dynamic.field("id", dynamic.string)(data))
  use title <- result.try(dynamic.field("title", dynamic.string)(data))
  use slug <- result.try(dynamic.field("slug", dynamic.string)(data))
  use content <- result.try(dynamic.field("content", dynamic.string)(data))
  Ok(Post(id, title, slug, content))
}

// Use it
case supabase.execute(query) {
  Ok(response) -> {
    case dynamic.list(decode_post)(response) {
      Ok(posts) -> // List(Post)
      Error(errors) -> // Decode errors
    }
  }
  Error(error) -> // Query error
}
```

## Available Query Methods

### Filtering
- `eq(column, value)` - Equals
- `not_eq(column, value)` - Not equals
- `gt(column, value)` - Greater than
- `lt(column, value)` - Less than
- `gte(column, value)` - Greater than or equal
- `lte(column, value)` - Less than or equal
- `like(column, pattern)` - Pattern matching (case sensitive)
- `ilike(column, pattern)` - Pattern matching (case insensitive)
- `in(column, values)` - In array of values
- `or(filters)` - OR conditions

### Ordering & Pagination
- `order(column, ascending)` - Sort results
- `limit(count)` - Limit number of results
- `range(from, to)` - Get specific range of results

### Row Selection
- `single()` - Expect exactly one result
- `maybe_single()` - Expect zero or one result

## Testing

Run the test suite:

```bash
# For Erlang target
cd supabase/erlang
gleam test

# For JavaScript target
cd supabase
gleam test --target javascript
```

## Implementation Status

### ✅ Implemented
- Basic CRUD operations
- Query building
- Filtering operations
- Ordering and pagination
- Single record queries
- RPC calls
- Error handling
- URL building with proper encoding

### 🚧 Not Yet Implemented
- Realtime subscriptions
- Authentication helpers
- Storage operations
- Advanced PostgREST features (embedding, computed fields)
- Response caching

## Platform-Specific Notes

### Erlang Target
- Uses `gleam_httpc` for HTTP requests
- Fully functional for server-side applications

### JavaScript Target
- Uses browser's fetch API or Node.js HTTP client
- Suitable for client-side applications

## Contributing

Feel free to contribute additional features or improvements!

## License

This implementation follows the same license as the parent TandemX project.