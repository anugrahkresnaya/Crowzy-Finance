# Agent Implementation Guide

## General Rules

- Follow clean architecture principles
- Do NOT mix UI and data logic
- Prefer composition over inheritance
- Keep functions small and testable

---

## Code Standards

### Flutter / Dart
- Use null safety
- Use `const` constructors where possible
- Avoid unnecessary rebuilds
- Follow lint rules (flutter_lints)

---

## State Management

- Use Riverpod (NOT Provider or Bloc)
- Use:
  - `StateNotifierProvider` for business logic
  - `FutureProvider` for async fetch
- Avoid global mutable state

---

## Data Handling

### Local (Hive)
- Use Hive for caching transactions
- Use adapters for models
- Keep schema simple

### Remote (Supabase)
- Use typed queries
- Always filter by `user_id`
- NEVER fetch entire dataset without pagination

---

## Security Rules (CRITICAL)

- Assume RLS is enabled
- NEVER bypass user_id filtering logic
- NEVER expose service role key in client

---

## API Interaction

- Wrap Supabase calls in repository layer
- Handle errors gracefully
- Retry failed sync operations

---

## UI Rules

- Keep widgets small and reusable
- Separate:
  - Screen
  - Components
- Avoid deeply nested widgets

---

## Folder Conventions

Each feature must contain:
feature/
├── ui/
├── providers/
├── models/
├── repository/

---

## Naming Conventions

- Models: `TransactionModel`
- Providers: `transactionProvider`
- Files: snake_case

---

## Performance Constraints

- Avoid unnecessary rebuilds
- Use `.select()` in Riverpod when needed
- Debounce frequent updates

---

## Error Handling

- Always handle:
  - Network failure
  - Empty state
  - Invalid input

---

## Sync Logic

- Queue unsynced data locally
- Retry sync when online
- Do NOT block UI on network

---

## Testing (Optional but Recommended)

- Unit test:
  - Repositories
  - Providers

---

## What NOT to Do

- ❌ Don’t call Supabase directly from UI
- ❌ Don’t store business logic in widgets
- ❌ Don’t skip local storage
- ❌ Don’t disable RLS

---

## Output Expectation

When generating code:
- Provide complete, runnable snippets
- Include imports
- Avoid pseudo-code
