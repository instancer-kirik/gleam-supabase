import gleam/dynamic
import gleam/json
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import supabase.{
  HttpRequestError, create, delete, eq,
  execute, from, insert, rpc, select, update,
}

pub fn main() {
  gleeunit.main()
}

// Client creation tests
pub fn create_client_test() {
  let client = create("https://example.supabase.co", "test-key")
  client.host |> should.equal("https://example.supabase.co")
  client.key |> should.equal("test-key")
}

// QueryBuilder tests
pub fn from_creates_query_builder_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = from(client, "users")
  
  builder.table |> should.equal("users")
  builder.method |> should.equal("GET")
  builder.select_columns |> should.equal(Some("*"))
  builder.filters |> should.equal([])
  builder.body |> should.equal(None)
  builder.expect_single |> should.equal(False)
}

pub fn select_sets_columns_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = 
    client
    |> from("users")
    |> select("id, name, email")
  
  builder.select_columns |> should.equal(Some("id, name, email"))
  builder.method |> should.equal("GET")
}

pub fn insert_sets_body_and_method_test() {
  let client = create("https://example.supabase.co", "test-key")
  let data = json.object([
    #("name", json.string("John Doe")),
    #("email", json.string("john@example.com")),
  ])
  
  let builder = 
    client
    |> from("users")
    |> insert(data)
  
  builder.body |> should.equal(Some(data))
  builder.method |> should.equal("POST")
}

pub fn update_sets_body_and_method_test() {
  let client = create("https://example.supabase.co", "test-key")
  let data = json.object([
    #("name", json.string("Jane Doe")),
  ])
  
  let builder = 
    client
    |> from("users")
    |> update(data)
  
  builder.body |> should.equal(Some(data))
  builder.method |> should.equal("PATCH")
}

pub fn delete_sets_method_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = 
    client
    |> from("users")
    |> delete()
  
  builder.method |> should.equal("DELETE")
}

pub fn eq_adds_filter_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = 
    client
    |> from("users")
    |> eq("id", "123")
  
  builder.filters |> should.equal([#("eq", "id", "123")])
}

pub fn multiple_filters_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = 
    client
    |> from("users")
    |> eq("status", "active")
    |> eq("role", "admin")
  
  builder.filters |> should.equal([
    #("eq", "status", "active"),
    #("eq", "role", "admin"),
  ])
}

// URL building tests
pub fn build_url_basic_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = from(client, "users")
  
  // We can't directly test build_url as it's private, but we can test through execute
  // For now, we'll test the QueryBuilder state which affects URL building
  builder.table |> should.equal("users")
  builder.select_columns |> should.equal(Some("*"))
}

pub fn build_url_with_select_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = 
    client
    |> from("users")
    |> select("id, name")
  
  builder.select_columns |> should.equal(Some("id, name"))
}

pub fn build_url_with_filters_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = 
    client
    |> from("users")
    |> eq("status", "active")
  
  builder.filters |> should.equal([#("eq", "status", "active")])
}

// Execute tests (these will return errors since HTTP is not implemented)
pub fn execute_returns_http_error_test() {
  let client = create("https://example.supabase.co", "test-key")
  let result = 
    client
    |> from("users")
    |> execute()
  
  case result {
    Error(HttpRequestError(_)) -> Nil
    _ -> panic as "Expected HttpRequestError"
  }
}

// RPC tests
pub fn rpc_basic_test() {
  let client = create("https://example.supabase.co", "test-key")
  let params = json.object([])
  
  // This will return a mock response since HTTP is not implemented
  let result = rpc("test_function", params, client)
  
  case result {
    Ok(_) -> Nil
    Error(_) -> panic as "Expected Ok result"
  }
}

// Chain multiple operations test
pub fn chain_operations_test() {
  let client = create("https://example.supabase.co", "test-key")
  let data = json.object([
    #("name", json.string("Test User")),
    #("email", json.string("test@example.com")),
  ])
  
  let builder = 
    client
    |> from("users")
    |> insert(data)
    |> select("id, name, email")
  
  builder.method |> should.equal("POST")
  builder.body |> should.equal(Some(data))
  builder.select_columns |> should.equal(Some("id, name, email"))
}

// Complex filter chain test
pub fn complex_filter_chain_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = 
    client
    |> from("posts")
    |> select("id, title, author_id")
    |> eq("published", "true")
    |> eq("category", "tech")
    |> eq("author_id", "42")
  
  builder.filters |> should.equal([
    #("eq", "published", "true"),
    #("eq", "category", "tech"),
    #("eq", "author_id", "42"),
  ])
  builder.select_columns |> should.equal(Some("id, title, author_id"))
}

// Update with filter test
pub fn update_with_filter_test() {
  let client = create("https://example.supabase.co", "test-key")
  let data = json.object([
    #("status", json.string("archived")),
  ])
  
  let builder = 
    client
    |> from("posts")
    |> eq("id", "123")
    |> update(data)
  
  builder.method |> should.equal("PATCH")
  builder.body |> should.equal(Some(data))
  builder.filters |> should.equal([#("eq", "id", "123")])
}

// Delete with filter test
pub fn delete_with_filter_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = 
    client
    |> from("posts")
    |> eq("id", "123")
    |> delete()
  
  builder.method |> should.equal("DELETE")
  builder.filters |> should.equal([#("eq", "id", "123")])
}

// Test empty select
pub fn empty_select_test() {
  let client = create("https://example.supabase.co", "test-key")
  let builder = 
    client
    |> from("users")
    |> select("")
  
  builder.select_columns |> should.equal(Some(""))
}

// Test multiple table operations
pub fn multiple_table_operations_test() {
  let client = create("https://example.supabase.co", "test-key")
  
  let users_builder = from(client, "users")
  let posts_builder = from(client, "posts")
  
  users_builder.table |> should.equal("users")
  posts_builder.table |> should.equal("posts")
  
  // Ensure they are independent
  users_builder.client |> should.equal(posts_builder.client)
  users_builder.table |> should.not_equal(posts_builder.table)
}

// Test client reuse
pub fn client_reuse_test() {
  let client = create("https://example.supabase.co", "test-key")
  
  let builder1 = 
    client
    |> from("users")
    |> eq("active", "true")
  
  let builder2 = 
    client
    |> from("posts")
    |> eq("published", "true")
  
  // Ensure builders are independent
  builder1.table |> should.equal("users")
  builder2.table |> should.equal("posts")
  builder1.filters |> should.equal([#("eq", "active", "true")])
  builder2.filters |> should.equal([#("eq", "published", "true")])
}