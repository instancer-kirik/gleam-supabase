# Gleam Supabase - Quick Start Guide

Get up and running with the Gleam Supabase client in minutes!

## Installation

Add `supabase` to your `gleam.toml` dependencies:

```toml
[dependencies]
supabase = "~> 0.1"
```

Then download dependencies:

```bash
gleam deps download
```

## Basic Setup

```gleam
import supabase
import gleam/json
import gleam/io
import gleam/result

pub fn main() {
  // Initialize the client
  let client = supabase.create(
    "https://your-project.supabase.co",
    "your-anon-key"
  )
  
  // Your first query
  let result = 
    client
    |> supabase.from("users")
    |> supabase.select("*")
    |> supabase.execute()
  
  case result {
    Ok(data) -> io.println("Success! Got data")
    Error(err) -> io.println("Error occurred")
  }
}
```

## Common Examples

### 1. Fetch Data with Filtering

```gleam
// Get active users sorted by name
let active_users = 
  client
  |> supabase.from("users")
  |> supabase.select("id, name, email")
  |> supabase.eq("active", "true")
  |> supabase.order("name", True)  // ascending
  |> supabase.execute()
```

### 2. Insert Data

```gleam
let new_user = json.object([
  #("name", json.string("Alice")),
  #("email", json.string("alice@example.com")),
  #("active", json.bool(True)),
])

let result = 
  client
  |> supabase.from("users")
  |> supabase.insert(new_user)
  |> supabase.select("*")  // Return the inserted record
  |> supabase.execute()
```

### 3. Update Data

```gleam
let updates = json.object([
  #("name", json.string("Alice Smith")),
])

let result = 
  client
  |> supabase.from("users")
  |> supabase.eq("email", "alice@example.com")
  |> supabase.update(updates)
  |> supabase.execute()
```

### 4. Delete Data

```gleam
let result = 
  client
  |> supabase.from("users")
  |> supabase.eq("id", "user-123")
  |> supabase.delete()
  |> supabase.execute()
```

### 5. Complex Queries

```gleam
// Find posts by category with author info
let posts = 
  client
  |> supabase.from("posts")
  |> supabase.select("*, author:users(name, email)")
  |> supabase.eq("category", "technology")
  |> supabase.gte("created_at", "2024-01-01")
  |> supabase.order("created_at", False)
  |> supabase.limit(10)
  |> supabase.execute()
```

## Error Handling

```gleam
import supabase.{ApiError, DecodeError, HttpRequestError}

case supabase.execute(query) {
  Ok(data) -> {
    // Process your data
    io.println("Success!")
  }
  
  Error(HttpRequestError(msg)) -> {
    io.println("Network error: " <> msg)
  }
  
  Error(ApiError(status, body)) -> {
    io.println("API error " <> int.to_string(status) <> ": " <> body)
  }
  
  Error(DecodeError(err)) -> {
    io.println("Failed to decode response")
  }
  
  Error(_) -> {
    io.println("Unknown error occurred")
  }
}
```

## Working with Types

Define your data types and create decoders:

```gleam
import gleam/dynamic
import gleam/result

// Define your type
pub type User {
  User(id: String, name: String, email: String, active: Bool)
}

// Create a decoder
fn decode_user(data: dynamic.Dynamic) -> Result(User, List(dynamic.DecodeError)) {
  use id <- result.try(dynamic.field("id", dynamic.string)(data))
  use name <- result.try(dynamic.field("name", dynamic.string)(data))
  use email <- result.try(dynamic.field("email", dynamic.string)(data))
  use active <- result.try(dynamic.field("active", dynamic.bool)(data))
  Ok(User(id, name, email, active))
}

// Use it with queries
pub fn get_users(client: supabase.Client) {
  let result = 
    client
    |> supabase.from("users")
    |> supabase.select("*")
    |> supabase.execute()
  
  case result {
    Ok(response) -> {
      // Decode the list of users
      case dynamic.list(decode_user)(response) {
        Ok(users) -> {
          // users is List(User)
          list.each(users, fn(user) {
            io.println(user.name <> " - " <> user.email)
          })
        }
        Error(errors) -> io.println("Decode error")
      }
    }
    Error(err) -> io.println("Query error")
  }
}
```

## RPC Functions

Call PostgreSQL functions:

```gleam
let params = json.object([
  #("user_id", json.string("123")),
  #("status", json.string("active")),
])

let result = supabase.rpc("get_user_stats", params, client)
```

## Single Record Queries

```gleam
// Expect exactly one result
let user = 
  client
  |> supabase.from("users")
  |> supabase.select("*")
  |> supabase.eq("id", "user-123")
  |> supabase.single()
  |> supabase.execute()

// Expect zero or one result
let maybe_user = 
  client
  |> supabase.from("users")
  |> supabase.select("*")
  |> supabase.eq("email", "alice@example.com")
  |> supabase.maybe_single()
  |> supabase.execute()
```

## Environment Variables

For security, store your Supabase credentials in environment variables:

```gleam
import gleam/erlang/os

pub fn create_client() {
  let assert Ok(url) = os.get_env("SUPABASE_URL")
  let assert Ok(key) = os.get_env("SUPABASE_ANON_KEY")
  
  supabase.create(url, key)
}
```

## Platform-Specific Notes

### JavaScript Target
```bash
gleam run --target javascript
```

### Erlang Target
```bash
gleam run --target erlang
```

Both targets support the same API!

## Next Steps

- Read the [full documentation](README.md)
- Check out the [examples](test/)
- Join the [Gleam Discord](https://discord.gg/Fm8Pwmy)
- Report issues on [GitHub](https://github.com/instancer-kirik/gleam-supabase)

Happy coding with Gleam and Supabase! 🚀✨