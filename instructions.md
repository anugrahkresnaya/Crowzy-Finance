# Claude Usage Instructions

## Purpose
This document defines how to use Claude AI effectively for this project.

Claude MUST follow:
- claude.md → product + architecture context
- agent.md → implementation rules

---

## How to Use

### Step 1 — Load Context
When starting a new session in Claude:

Paste this:

"I am working on a Flutter personal finance app.

Follow the specifications in:
- claude.md (project overview & architecture)
- agent.md (coding rules & constraints)

I will provide tasks incrementally. Do not deviate from the defined architecture."

Then paste the contents of:
- claude.md
- agent.md

---

### Step 2 — Task Prompt Format

Always give structured tasks like:

"Task:
Implement transaction creation feature.

Requirements:
- Use Riverpod
- Save locally with Hive
- Sync to Supabase
- Follow repository pattern

Output:
- Full runnable code
- Include imports
- No pseudo code"

---

### Step 3 — Rules for Claude

Claude must:

- Follow defined folder structure
- Use Riverpod (not other state management)
- Use Supabase directly (no Node backend)
- Assume RLS is enabled
- Separate UI, logic, and data layers
- Provide complete code (no placeholders)

---

### Step 4 — Iteration Strategy

Work feature by feature:

1. Auth
2. Transactions
3. Categories
4. Wishlist
5. Sync

Do NOT ask Claude to build everything at once.

---

## Important Constraints

- Do not redesign architecture
- Do not introduce new libraries unless necessary
- Keep code production-ready
- Prefer simplicity over abstraction

---

## Example Prompt

"Implement transaction list screen.

Requirements:
- Fetch from local DB (Hive)
- Sync from Supabase
- Use Riverpod provider
- Paginate remote data

Output:
- Screen UI
- Provider
- Repository
- Model"

---

## Notes

Claude performs best when:
- Context is repeated at start
- Tasks are specific
- Scope is controlled

Avoid vague prompts like:
"build the app"
