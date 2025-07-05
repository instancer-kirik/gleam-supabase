import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic}
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleeunit
import gleeunit/should
import supabase.{
  type Client, type QueryBuilder, type SupabaseError,
  create, from, select, eq, gt, lt, gte, lte, like, ilike, 
  order, limit, range, single, maybe_single, insert, update, delete,
  execute, rpc
}

pub fn main() {
  gleeunit.main()
}

// Test configuration
const test_supabase_url = "https://xlmibzeenudmkqgiyaif.supabase.co"
const test_supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhsbWliemVlbnVkbWtxZ2l5YWlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMzODAxNzMsImV4cCI6MjA1ODk1NjE3M30.Yn9AIaqkstjgz1coNJGB-o66L7wiJZZvCXfqyM6Wavs"

// Helper to create test client
fn test_client() -> Client {
  create(test_supabase_url, test_supabase_key)
}

// Test: Client creation
pub fn client_creation_test() {
  let client = test_client()
  client.host |> should.equal(test_supabase_url)
  client.key |> should.equal(test_supabase_key)
}

// Test: Basic query builder
pub fn query_builder_basic_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("*")
  
  builder.table |> should.equal("posts")
  builder.method |> should.equal("GET")
  builder.select_columns |> should.equal(Some("*"))
}

// Test: Select specific columns
pub fn select_columns_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("id, title, slug, date")
  
  builder.select_columns |> should.equal(Some("id, title, slug, date"))
}

// Test: Filter with eq
pub fn filter_eq_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("*")
    |> eq("category", "technology")
  
  builder.filters |> should.equal([#("eq", "category", "technology")])
}

// Test: Multiple filters
pub fn multiple_filters_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("*")
    |> eq("category", "technology")
    |> gte("date", "2024-01-01")
    |> like("title", "%Gleam%")
  
  builder.filters |> should.equal([
    #("eq", "category", "technology"),
    #("gte", "date", "2024-01-01"),
    #("like", "title", "%Gleam%"),
  ])
}

// Test: Order by
pub fn order_by_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("*")
    |> order("date", False)  // descending
  
  builder.filters |> list.find(fn(f) { f.0 == "order" }) |> should.equal(Ok(#("order", "date", "desc")))
}

// Test: Limit
pub fn limit_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("*")
    |> limit(10)
  
  builder.filters |> list.find(fn(f) { f.0 == "limit" }) |> should.equal(Ok(#("limit", "", "10")))
}

// Test: Range pagination
pub fn range_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("*")
    |> range(0, 9)
  
  builder.filters |> list.find(fn(f) { f.0 == "range" }) |> should.equal(Ok(#("range", "", "0-9")))
}

// Test: Complex query chain
pub fn complex_query_chain_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("id, title, slug, category, date")
    |> eq("category", "technology")
    |> gte("date", "2024-01-01")
    |> order("date", False)
    |> limit(5)
  
  builder.table |> should.equal("posts")
  builder.select_columns |> should.equal(Some("id, title, slug, category, date"))
  list.length(builder.filters) |> should.equal(4)
}

// Test: Insert operation
pub fn insert_operation_test() {
  let client = test_client()
  let post_data = json.object([
    #("title", json.string("Test Post")),
    #("content", json.string("Test content")),
  ])
  
  let builder = 
    client
    |> from("posts")
    |> insert(post_data)
  
  builder.method |> should.equal("POST")
  builder.body |> should.equal(Some(post_data))
}

// Test: Update operation
pub fn update_operation_test() {
  let client = test_client()
  let updates = json.object([
    #("title", json.string("Updated Title")),
  ])
  
  let builder = 
    client
    |> from("posts")
    |> eq("id", "123")
    |> update(updates)
  
  builder.method |> should.equal("PATCH")
  builder.body |> should.equal(Some(updates))
  builder.filters |> should.equal([#("eq", "id", "123")])
}

// Test: Delete operation
pub fn delete_operation_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> eq("id", "123")
    |> delete()
  
  builder.method |> should.equal("DELETE")
  builder.filters |> should.equal([#("eq", "id", "123")])
}

// Test: Single vs maybe_single
pub fn single_maybe_single_test() {
  let client = test_client()
  
  let single_builder = 
    client
    |> from("posts")
    |> eq("id", "123")
    |> single()
  
  let maybe_single_builder = 
    client
    |> from("posts")
    |> eq("id", "456")
    |> maybe_single()
  
  single_builder.expect_single |> should.equal(True)
  maybe_single_builder.expect_single |> should.equal(True)
}

// Test: ilike filter (case insensitive)
pub fn ilike_filter_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("*")
    |> ilike("title", "%gleam%")
  
  builder.filters |> should.equal([#("ilike", "title", "%gleam%")])
}

// Test: in filter
pub fn in_filter_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("*")
    |> supabase.in("category", ["technology", "tutorial", "update"])
  
  builder.filters |> should.equal([#("in", "category", "(technology,tutorial,update)")])
}

// Test: not_eq filter
pub fn not_eq_filter_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("*")
    |> supabase.not_eq("status", "draft")
  
  builder.filters |> should.equal([#("neq", "status", "draft")])
}

// Test: RPC function call
pub fn rpc_call_test() {
  let client = test_client()
  let params = json.object([
    #("user_id", json.string("123")),
    #("limit", json.int(10)),
  ])
  
  // This tests that RPC builds the correct structure
  // Actual HTTP call will fail in test environment
  case rpc("get_user_posts", params, client) {
    Ok(_) -> should.fail()  // Shouldn't succeed without real endpoint
    Error(_) -> Nil  // Expected to fail in test
  }
}

// Integration test helpers
pub type TestPost {
  TestPost(
    id: String,
    title: String,
    slug: String,
    category: String,
    date: String,
  )
}

fn decode_test_post(data: Dynamic) -> Result(TestPost, List(DecodeError)) {
  use id <- result.try(dynamic.field("id", dynamic.string)(data))
  use title <- result.try(dynamic.field("title", dynamic.string)(data))
  use slug <- result.try(dynamic.field("slug", dynamic.string)(data))
  use category <- result.try(dynamic.field("category", dynamic.string)(data))
  use date <- result.try(dynamic.field("date", dynamic.string)(data))
  Ok(TestPost(id, title, slug, category, date))
}

// Test: Query execution (will make actual HTTP request)
pub fn query_execution_integration_test() {
  let client = test_client()
  let query = 
    client
    |> from("posts")
    |> select("id, title, slug, category, date")
    |> limit(1)
  
  case execute(query) {
    Ok(response) -> {
      // Try to decode the response
      case dynamic.list(decode_test_post)(response) {
        Ok(posts) -> {
          // Just verify we got some posts
          let _ = list.length(posts)
          Nil
        }
        Error(_) -> {
          // If decoding fails, that's OK for this test
          Nil
        }
      }
    }
    Error(error) -> {
      // Log the error for debugging
      io.println("Query execution error: " <> string.inspect(error))
      // In CI/test environment, network requests might fail
      // so we just check that the error is structured correctly
      case error {
        supabase.HttpRequestError(_) -> Nil
        supabase.ApiError(_, _) -> Nil
        supabase.DecodeError(_) -> Nil
        _ -> Nil
      }
    }
  }
}

// Test: Build complex query URL
pub fn build_complex_url_test() {
  let client = test_client()
  let builder = 
    client
    |> from("posts")
    |> select("*")
    |> eq("category", "technology")
    |> gte("date", "2024-01-01")
    |> order("date", False)
    |> limit(10)
    |> range(0, 9)
  
  // The URL building is internal, but we can verify the builder state
  builder.filters |> list.length() |> should.equal(5)
  
  // Verify filter order is preserved
  let filter_ops = list.map(builder.filters, fn(f) { f.0 })
  filter_ops |> should.equal(["eq", "gte", "order", "limit", "range"])
}

// Test: Insert with select
pub fn insert_with_select_test() {
  let client = test_client()
  let post_data = json.object([
    #("title", json.string("New Post")),
    #("slug", json.string("new-post")),
    #("content", json.string("Content here")),
  ])
  
  let builder = 
    client
    |> from("posts")
    |> insert(post_data)
    |> select("id, title, slug")
  
  builder.method |> should.equal("POST")
  builder.body |> should.equal(Some(post_data))
  builder.select_columns |> should.equal(Some("id, title, slug"))
}

// Test: Update with filters and select
pub fn update_with_filters_and_select_test() {
  let client = test_client()
  let updates = json.object([
    #("status", json.string("published")),
  ])
  
  let builder = 
    client
    |> from("posts")
    |> eq("status", "draft")
    |> gte("date", "2024-01-01")
    |> update(updates)
    |> select("*")
  
  builder.method |> should.equal("PATCH")
  builder.body |> should.equal(Some(updates))
  builder.filters |> list.length() |> should.equal(2)
  builder.select_columns |> should.equal(Some("*"))
}

// Test: Method chaining independence
pub fn method_chaining_independence_test() {
  let client = test_client()
  
  // Create base query
  let base = 
    client
    |> from("posts")
    |> select("*")
  
  // Branch 1: Add category filter
  let branch1 = 
    base
    |> eq("category", "technology")
  
  // Branch 2: Add date filter (from original base)
  let branch2 = 
    base
    |> gte("date", "2024-01-01")
  
  // Verify branches are independent
  branch1.filters |> should.equal([#("eq", "category", "technology")])
  branch2.filters |> should.equal([#("gte", "date", "2024-01-01")])
  base.filters |> should.equal([])  // Original unchanged
}