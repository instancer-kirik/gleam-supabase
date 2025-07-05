# Contributing to Gleam Supabase

Thank you for your interest in contributing to the Gleam Supabase client! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct: be respectful, inclusive, and constructive in all interactions.

## How to Contribute

### Reporting Issues

- Check existing issues to avoid duplicates
- Use issue templates when available
- Include relevant details:
  - Gleam version
  - Target (JavaScript/Erlang)
  - Minimal reproduction example
  - Error messages
  - Expected vs actual behavior

### Suggesting Features

- Open an issue with the "enhancement" label
- Explain the use case and benefits
- Consider implementation approach
- Be open to discussion and feedback

### Submitting Changes

1. **Fork the repository**
   ```bash
   git clone https://github.com/instancer-kirik/gleam-supabase.git
   cd gleam-supabase
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation as needed
   - Ensure all tests pass

4. **Test your changes**
   ```bash
   # Test JavaScript target
   gleam test --target javascript
   
   # Test Erlang target
   cd erlang
   gleam test
   ```

5. **Commit your changes**
   - Use clear, descriptive commit messages
   - Follow conventional commits format:
     - `feat:` for new features
     - `fix:` for bug fixes
     - `docs:` for documentation changes
     - `test:` for test additions/changes
     - `refactor:` for code refactoring
     - `chore:` for maintenance tasks

6. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```
   - Fill out the PR template
   - Link related issues
   - Ensure CI passes

## Development Setup

### Prerequisites

- Gleam 1.0.0 or later
- Erlang/OTP 25.0 or later (for Erlang target)
- Node.js 18.0 or later (for JavaScript target)

### Local Development

1. **Install dependencies**
   ```bash
   gleam deps download
   ```

2. **Run tests**
   ```bash
   # JavaScript target
   gleam test --target javascript
   
   # Erlang target
   cd erlang
   gleam test
   ```

3. **Build the project**
   ```bash
   gleam build
   ```

4. **Format code**
   ```bash
   gleam format
   ```

## Project Structure

```
supabase/
├── src/                    # JavaScript target source
│   ├── supabase.gleam     # Main module
│   └── supabase_ffi.gleam # FFI bindings
├── erlang/                 # Erlang target
│   ├── src/               # Erlang-specific source
│   └── test/              # Erlang-specific tests
├── test/                   # JavaScript target tests
├── gleam.toml             # JavaScript target config
└── README.md              # Documentation
```

## Testing Guidelines

- Write tests for all new functionality
- Maintain or improve code coverage
- Test both success and error cases
- Use descriptive test names
- Group related tests using describe blocks
- Mock external API calls when possible

### Running Specific Tests

```bash
# Run tests matching a pattern
gleam test -- --filter "test_name_pattern"
```

## Documentation

- Update README.md for user-facing changes
- Add code examples for new features
- Document all public functions
- Use clear, concise language
- Include type signatures in examples

## Code Style

- Follow Gleam's official style guide
- Use `gleam format` before committing
- Prefer descriptive variable names
- Keep functions small and focused
- Use type annotations for clarity
- Add comments for complex logic

## API Design Principles

1. **Type Safety**: Leverage Gleam's type system
2. **Ergonomics**: Make the API pleasant to use
3. **Consistency**: Follow established patterns
4. **Error Handling**: Use Result types appropriately
5. **Documentation**: Every public function needs docs

## Release Process

Releases are managed by maintainers:

1. Update version in `gleam.toml`
2. Update CHANGELOG.md
3. Create a git tag
4. Publish to Hex.pm
5. Create GitHub release

## Getting Help

- Open an issue for questions
- Join the Gleam Discord server
- Check existing documentation
- Look at test examples

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

Thank you for contributing to Gleam Supabase! 🎉