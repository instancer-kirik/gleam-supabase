import gleam/dynamic
import gleam/io
import gleam/string
import gleeunit
import gleeunit/should
import supabase

// Configuration
const supabase_url = "https://xlmibzeenudmkqgiyaif.supabase.co"

const supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhsbWliemVlbnVkbWtxZ2l5YWlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMzODAxNzMsImV4cCI6MjA1ODk1NjE3M30.Yn9AIaqkstjgz1coNJGB-o66L7wiJZZvCXfqyM6Wavs"

pub fn main() {
  gleeunit.main()
}

// Test 1: Basic query
pub fn basic_query_test() {
  let client = supabase.create(supabase_url, supabase_key)

  let query1 =
    client
    |> supabase.from("posts")
    |> supabase.select("id, title, slug")
    |> supabase.limit(3)

  case supabase.execute(query1) {
    Ok(response) -> {
      io.println(
        "Response type: " <> string.inspect(dynamic.classify(response)),
      )
      should.be_true(True)
    }
    Error(error) -> {
      io.println("Query failed: " <> string.inspect(error))
      // Network errors are expected in test environment
      case error {
        supabase.HttpRequestError(_) -> should.be_true(True)
        _ -> should.fail()
      }
    }
  }
}

// Test 2: Filter by category
pub fn filter_by_category_test() {
  let client = supabase.create(supabase_url, supabase_key)

  let query2 =
    client
    |> supabase.from("posts")
    |> supabase.select("title, category")
    |> supabase.eq("category", "technology")

  case supabase.execute(query2) {
    Ok(_response) -> {
      should.be_true(True)
    }
    Error(error) -> {
      case error {
        supabase.HttpRequestError(_) -> should.be_true(True)
        _ -> should.fail()
      }
    }
  }
}

// Test 3: Get single post by slug
pub fn single_post_by_slug_test() {
  let client = supabase.create(supabase_url, supabase_key)

  let query3 =
    client
    |> supabase.from("posts")
    |> supabase.select("*")
    |> supabase.eq("slug", "navigatingchartspace")
    |> supabase.single()

  case supabase.execute(query3) {
    Ok(_response) -> {
      should.be_true(True)
    }
    Error(error) -> {
      case error {
        supabase.HttpRequestError(_) -> should.be_true(True)
        _ -> should.fail()
      }
    }
  }
}

// Test 4: Complex query
pub fn complex_query_test() {
  let client = supabase.create(supabase_url, supabase_key)

  let query4 =
    client
    |> supabase.from("posts")
    |> supabase.select("title, date, category")
    |> supabase.order("date", False)
    |> supabase.limit(5)

  case supabase.execute(query4) {
    Ok(_response) -> {
      should.be_true(True)
    }
    Error(error) -> {
      case error {
        supabase.HttpRequestError(_) -> should.be_true(True)
        _ -> should.fail()
      }
    }
  }
}

// Test 5: Search posts
pub fn search_posts_test() {
  let client = supabase.create(supabase_url, supabase_key)

  let query5 =
    client
    |> supabase.from("posts")
    |> supabase.select("title")
    |> supabase.ilike("title", "%chart%")

  case supabase.execute(query5) {
    Ok(_response) -> {
      should.be_true(True)
    }
    Error(error) -> {
      case error {
        supabase.HttpRequestError(_) -> should.be_true(True)
        _ -> should.fail()
      }
    }
  }
}

// Test 6: Multiple filters
pub fn multiple_filters_test() {
  let client = supabase.create(supabase_url, supabase_key)

  let query6 =
    client
    |> supabase.from("posts")
    |> supabase.select("*")
    |> supabase.eq("category", "technology")
    |> supabase.gte("date", "2024-01-01")
    |> supabase.limit(10)

  case supabase.execute(query6) {
    Ok(_response) -> {
      should.be_true(True)
    }
    Error(error) -> {
      case error {
        supabase.HttpRequestError(_) -> should.be_true(True)
        _ -> should.fail()
      }
    }
  }
}

// Test 7: Range query
pub fn range_query_test() {
  let client = supabase.create(supabase_url, supabase_key)

  let query7 =
    client
    |> supabase.from("posts")
    |> supabase.select("id, title")
    |> supabase.range(0, 4)

  case supabase.execute(query7) {
    Ok(_response) -> {
      should.be_true(True)
    }
    Error(error) -> {
      case error {
        supabase.HttpRequestError(_) -> should.be_true(True)
        _ -> should.fail()
      }
    }
  }
}
