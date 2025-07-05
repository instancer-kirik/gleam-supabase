import gleam/dynamic
import gleam/json
import gleeunit
import supabase.{
  create, delete, eq,
  execute, from, insert, rpc, select, update,
}

pub fn main() {
  gleeunit.main()
}

// Integration test for full query flow
pub fn full_query_flow_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let result = 
    client
    |> from("users")
    |> select("id, name, email")
    |> eq("active", "true")
    |> eq("role", "admin")
    |> execute()
  
  // Since HTTP isn't implemented, we expect an error
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Integration test for insert flow
pub fn insert_flow_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let user_data = json.object([
    #("name", json.string("Test User")),
    #("email", json.string("test@example.com")),
    #("metadata", json.object([
      #("source", json.string("test_suite")),
      #("timestamp", json.int(1234567890)),
    ])),
  ])
  
  let result = 
    client
    |> from("users")
    |> insert(user_data)
    |> select("id, name, email")
    |> execute()
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Integration test for update flow
pub fn update_flow_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let update_data = json.object([
    #("name", json.string("Updated Name")),
    #("updated_at", json.string("2024-01-01T00:00:00Z")),
  ])
  
  let result = 
    client
    |> from("users")
    |> eq("id", "user-123")
    |> update(update_data)
    |> select("id, name, updated_at")
    |> execute()
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Integration test for delete flow
pub fn delete_flow_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let result = 
    client
    |> from("users")
    |> eq("id", "user-to-delete")
    |> delete()
    |> execute()
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Integration test for RPC call
pub fn rpc_call_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let params = json.object([])
  
  let result = rpc("get_user_posts", params, client)
  
  // RPC should return Ok with mock data for now
  case result {
    Ok(_) -> Nil
    Error(_) -> panic as "Expected Ok result"
  }
}

// Test complex filtering scenarios
pub fn complex_filtering_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let result = 
    client
    |> from("products")
    |> select("id, name, price, category, stock")
    |> eq("category", "electronics")
    |> eq("in_stock", "true")
    |> eq("price_range", "100-500")
    |> eq("brand", "TechCorp")
    |> execute()
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Test bulk insert scenario
pub fn bulk_insert_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let items = json.preprocessed_array([
    json.object([
      #("name", json.string("Item 1")),
      #("price", json.float(19.99)),
    ]),
    json.object([
      #("name", json.string("Item 2")),
      #("price", json.float(29.99)),
    ]),
    json.object([
      #("name", json.string("Item 3")),
      #("price", json.float(39.99)),
    ]),
  ])
  
  let result = 
    client
    |> from("products")
    |> insert(items)
    |> execute()
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Test partial update scenario
pub fn partial_update_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let partial_update = json.object([
    #("last_login", json.string("2024-01-01T12:00:00Z")),
    #("login_count", json.int(42)),
  ])
  
  let result = 
    client
    |> from("user_stats")
    |> eq("user_id", "user-123")
    |> update(partial_update)
    |> execute()
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Test query with no filters
pub fn query_no_filters_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let result = 
    client
    |> from("categories")
    |> select("id, name, description")
    |> execute()
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Test select all columns
pub fn select_all_columns_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let result = 
    client
    |> from("settings")
    |> execute()  // Default is select("*")
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Test nested JSON insert
pub fn nested_json_insert_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let nested_data = json.object([
    #("user_id", json.string("user-123")),
    #("profile", json.object([
      #("bio", json.string("Software developer")),
      #("links", json.object([
        #("github", json.string("https://github.com/user")),
        #("website", json.string("https://example.com")),
      ])),
      #("skills", json.preprocessed_array([
        json.string("Gleam"),
        json.string("Elixir"),
        json.string("TypeScript"),
      ])),
    ])),
    #("preferences", json.object([
      #("theme", json.string("dark")),
      #("notifications", json.object([
        #("email", json.bool(True)),
        #("push", json.bool(False)),
      ])),
    ])),
  ])
  
  let result = 
    client
    |> from("user_profiles")
    |> insert(nested_data)
    |> execute()
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Test multiple operations on same table
pub fn multiple_operations_same_table_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  // First operation: Insert
  let insert_data = json.object([
    #("title", json.string("New Post")),
    #("content", json.string("Post content")),
  ])
  
  let insert_result = 
    client
    |> from("posts")
    |> insert(insert_data)
    |> execute()
  
  // Second operation: Update
  let update_data = json.object([
    #("title", json.string("Updated Post")),
  ])
  
  let update_result = 
    client
    |> from("posts")
    |> eq("id", "post-123")
    |> update(update_data)
    |> execute()
  
  // Third operation: Select
  let select_result = 
    client
    |> from("posts")
    |> eq("author_id", "user-123")
    |> select("id, title, created_at")
    |> execute()
  
  // All should fail with HTTP error
  case insert_result, update_result, select_result {
    Error(supabase.HttpRequestError(_)), 
    Error(supabase.HttpRequestError(_)), 
    Error(supabase.HttpRequestError(_)) -> Nil
    _, _, _ -> panic as "Expected HttpRequestError for all operations"
  }
}

// Test edge cases with empty strings
pub fn empty_string_edge_cases_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let data_with_empty = json.object([
    #("name", json.string("")),
    #("description", json.string("")),
    #("tags", json.preprocessed_array([])),
  ])
  
  let result = 
    client
    |> from("items")
    |> insert(data_with_empty)
    |> execute()
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// Test with special characters in values
pub fn special_characters_values_test() {
  let client = create("https://test.supabase.co", "test-key-123")
  
  let special_data = json.object([
    #("title", json.string("Test with \"quotes\" and 'apostrophes'")),
    #("content", json.string("Line 1\nLine 2\tTabbed")),
    #("emoji", json.string("🚀 Gleam is awesome! 💎")),
    #("special", json.string("!@#$%^&*()_+-=[]{}|;:,.<>?")),
  ])
  
  let result = 
    client
    |> from("special_content")
    |> insert(special_data)
    |> execute()
  
  case result {
    Error(supabase.HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}