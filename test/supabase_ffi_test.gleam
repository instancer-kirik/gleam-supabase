import gleam/json
import gleam/option.{Some}
import gleam/string
import gleeunit
import gleeunit/should
import supabase_ffi.{
  create_client, filter_eq, insert_row, query_table, run_query, select_all,
  select_columns,
}

pub fn main() {
  gleeunit.main()
}

// Client creation test
pub fn create_client_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  client.host |> should.equal("https://example.supabase.co")
  client.key |> should.equal("test-api-key")
}

// Query table test
pub fn query_table_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let builder = query_table(client, "users")

  builder.table |> should.equal("users")
  builder.method |> should.equal("GET")
  builder.select_columns |> should.equal(Some("*"))
}

// Select all test
pub fn select_all_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let builder =
    client
    |> query_table("posts")
    |> select_all()

  builder.select_columns |> should.equal(Some("*"))
}

// Select columns test
pub fn select_columns_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let builder =
    client
    |> query_table("users")
    |> select_columns("id, name, email, created_at")

  builder.select_columns |> should.equal(Some("id, name, email, created_at"))
}

// Insert row test
pub fn insert_row_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let user_data =
    json.object([
      #("name", json.string("Alice Johnson")),
      #("email", json.string("alice@example.com")),
      #("age", json.int(28)),
      #("is_active", json.bool(True)),
    ])

  let builder =
    client
    |> query_table("users")
    |> insert_row(user_data)

  builder.method |> should.equal("POST")
  builder.body |> should.equal(Some(user_data))
}

// Filter equal test
pub fn filter_eq_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let builder =
    client
    |> query_table("products")
    |> filter_eq("category", "electronics")

  builder.filters |> should.equal([#("eq", "category", "electronics")])
}

// Complex query building test
pub fn complex_query_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let builder =
    client
    |> query_table("orders")
    |> select_columns("id, customer_id, total, status")
    |> filter_eq("status", "pending")
    |> filter_eq("customer_id", "cust_123")

  builder.table |> should.equal("orders")
  builder.select_columns |> should.equal(Some("id, customer_id, total, status"))
  builder.filters
  |> should.equal([
    #("eq", "status", "pending"),
    #("eq", "customer_id", "cust_123"),
  ])
}

// Run query test (will return error due to HTTP not implemented)
pub fn run_query_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let result =
    client
    |> query_table("users")
    |> select_all()
    |> run_query()

  // Since HTTP is not implemented, we expect an error
  case result {
    Error(error_msg) -> {
      error_msg
      |> string.contains("HTTP client not implemented")
      |> should.be_true()
    }
    Ok(_) -> panic as "Expected error but got Ok"
  }
}

// Insert and select test
pub fn insert_and_select_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let post_data =
    json.object([
      #("title", json.string("New Blog Post")),
      #("content", json.string("This is the content of the blog post")),
      #("author_id", json.int(42)),
      #(
        "tags",
        json.preprocessed_array([json.string("tech"), json.string("gleam")]),
      ),
    ])

  let builder =
    client
    |> query_table("posts")
    |> insert_row(post_data)
    |> select_columns("id, title, created_at")

  builder.method |> should.equal("POST")
  builder.body |> should.equal(Some(post_data))
  builder.select_columns |> should.equal(Some("id, title, created_at"))
}

// Multiple filters test
pub fn multiple_filters_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let builder =
    client
    |> query_table("products")
    |> select_columns("id, name, price")
    |> filter_eq("category", "books")
    |> filter_eq("in_stock", "true")
    |> filter_eq("price", "29.99")

  builder.filters
  |> should.equal([
    #("eq", "category", "books"),
    #("eq", "in_stock", "true"),
    #("eq", "price", "29.99"),
  ])
}

// Test empty column selection
pub fn empty_column_selection_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let builder =
    client
    |> query_table("users")
    |> select_columns("")

  builder.select_columns |> should.equal(Some(""))
}

// Test client reuse across multiple queries
pub fn client_reuse_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")

  let users_query =
    client
    |> query_table("users")
    |> filter_eq("active", "true")

  let posts_query =
    client
    |> query_table("posts")
    |> filter_eq("published", "true")

  let comments_query =
    client
    |> query_table("comments")
    |> select_columns("id, content, user_id")

  // Verify all queries use the same client
  users_query.client |> should.equal(client)
  posts_query.client |> should.equal(client)
  comments_query.client |> should.equal(client)

  // Verify queries are independent
  users_query.table |> should.equal("users")
  posts_query.table |> should.equal("posts")
  comments_query.table |> should.equal("comments")
}

// Test complex JSON data insertion
pub fn complex_json_insertion_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")

  let complex_data =
    json.object([
      #(
        "user_info",
        json.object([
          #("name", json.string("Bob Smith")),
          #("age", json.int(35)),
          #("verified", json.bool(True)),
        ]),
      ),
      #(
        "preferences",
        json.object([
          #("theme", json.string("dark")),
          #("notifications", json.bool(False)),
          #(
            "languages",
            json.preprocessed_array([
              json.string("english"),
              json.string("spanish"),
            ]),
          ),
        ]),
      ),
      #(
        "metadata",
        json.object([
          #("created_by", json.string("system")),
          #("version", json.float(1.5)),
        ]),
      ),
    ])

  let builder =
    client
    |> query_table("user_profiles")
    |> insert_row(complex_data)

  builder.body |> should.equal(Some(complex_data))
  builder.method |> should.equal("POST")
}

// Test numeric string filters
pub fn numeric_filter_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let builder =
    client
    |> query_table("transactions")
    |> filter_eq("amount", "99.99")
    |> filter_eq("user_id", "12345")

  builder.filters
  |> should.equal([#("eq", "amount", "99.99"), #("eq", "user_id", "12345")])
}

// Test special characters in table and column names
pub fn special_characters_test() {
  let client = create_client("https://example.supabase.co", "test-api-key")
  let builder =
    client
    |> query_table("user_profiles")
    |> select_columns("first_name, last_name, email_address")
    |> filter_eq("is_active", "true")

  builder.table |> should.equal("user_profiles")
  builder.select_columns
  |> should.equal(Some("first_name, last_name, email_address"))
}
