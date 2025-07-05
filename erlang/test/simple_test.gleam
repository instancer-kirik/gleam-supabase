import gleam/io
import gleam/string
import gleam/int
import gleam/list
import gleam/dynamic
import supabase

// Configuration
const supabase_url = "https://xlmibzeenudmkqgiyaif.supabase.co"
const supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhsbWliemVlbnVkbWtxZ2l5YWlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMzODAxNzMsImV4cCI6MjA1ODk1NjE3M30.Yn9AIaqkstjgz1coNJGB-o66L7wiJZZvCXfqyM6Wavs"

pub fn main() {
  io.println("\n🧪 Testing Gleam Supabase Client")
  io.println("================================\n")
  
  let client = supabase.create(supabase_url, supabase_key)
  
  // Test 1: Basic query
  io.println("Test 1: Basic query for posts...")
  let query1 = 
    client
    |> supabase.from("posts")
    |> supabase.select("id, title, slug")
    |> supabase.limit(3)
  
  case supabase.execute(query1) {
    Ok(response) -> {
      io.println("✅ Query successful!")
      io.println("Response type: " <> string.inspect(dynamic.classify(response)))
    }
    Error(error) -> {
      io.println("❌ Query failed: " <> string.inspect(error))
    }
  }
  
  // Test 2: Filter by category
  io.println("\n\nTest 2: Filter by category...")
  let query2 = 
    client
    |> supabase.from("posts")
    |> supabase.select("title, category")
    |> supabase.eq("category", "technology")
  
  case supabase.execute(query2) {
    Ok(_response) -> {
      io.println("✅ Filtered query successful!")
    }
    Error(error) -> {
      io.println("❌ Query failed: " <> string.inspect(error))
    }
  }
  
  // Test 3: Get single post by slug
  io.println("\n\nTest 3: Get single post by slug...")
  let query3 = 
    client
    |> supabase.from("posts")
    |> supabase.select("*")
    |> supabase.eq("slug", "navigatingchartspace")
    |> supabase.single()
  
  case supabase.execute(query3) {
    Ok(_response) -> {
      io.println("✅ Single post query successful!")
    }
    Error(error) -> {
      io.println("❌ Query failed: " <> string.inspect(error))
    }
  }
  
  // Test 4: Complex query
  io.println("\n\nTest 4: Complex query with ordering...")
  let query4 = 
    client
    |> supabase.from("posts")
    |> supabase.select("title, date, category")
    |> supabase.order("date", False)
    |> supabase.limit(5)
  
  case supabase.execute(query4) {
    Ok(_response) -> {
      io.println("✅ Complex query successful!")
    }
    Error(error) -> {
      io.println("❌ Query failed: " <> string.inspect(error))
    }
  }
  
  // Test 5: Search posts
  io.println("\n\nTest 5: Search posts with ilike...")
  let query5 = 
    client
    |> supabase.from("posts")
    |> supabase.select("title")
    |> supabase.ilike("title", "%chart%")
  
  case supabase.execute(query5) {
    Ok(_response) -> {
      io.println("✅ Search query successful!")
    }
    Error(error) -> {
      io.println("❌ Query failed: " <> string.inspect(error))
    }
  }
  
  // Test 6: Multiple filters
  io.println("\n\nTest 6: Multiple filters...")
  let query6 = 
    client
    |> supabase.from("posts")
    |> supabase.select("*")
    |> supabase.eq("category", "technology")
    |> supabase.gte("date", "2024-01-01")
    |> supabase.limit(10)
  
  case supabase.execute(query6) {
    Ok(_response) -> {
      io.println("✅ Multi-filter query successful!")
    }
    Error(error) -> {
      io.println("❌ Query failed: " <> string.inspect(error))
    }
  }
  
  // Test 7: Range query
  io.println("\n\nTest 7: Range query for pagination...")
  let query7 = 
    client
    |> supabase.from("posts")
    |> supabase.select("id, title")
    |> supabase.range(0, 4)
  
  case supabase.execute(query7) {
    Ok(_response) -> {
      io.println("✅ Range query successful!")
    }
    Error(error) -> {
      io.println("❌ Query failed: " <> string.inspect(error))
    }
  }
  
  io.println("\n\n✨ Test complete!")
  io.println("\nIf you see mostly ✅ marks above, your Gleam Supabase client is working!")
  io.println("Note: This test doesn't decode responses - it just verifies the queries execute.")
}