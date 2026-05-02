# Personal Finance Tracker (Flutter + Supabase)

## Overview
A cross-platform mobile application built with Flutter to help users track:
- Income
- Expenses
- Categories
- Wishlist (financial goals)

The system uses a hybrid architecture:
- Local-first (offline support)
- Supabase as backend (auth + sync)

---

## Tech Stack (Use Latest Stable)

### Frontend (Mobile)
- Flutter (stable)
- Dart (latest stable)
- State Management: Riverpod (v2+)
- Local Database: Hive (stable)

### Backend
- Supabase (PostgreSQL + Auth + Realtime optional)

---

## Core Features (MVP)

1. Authentication
   - Email/password via Supabase Auth

2. Transactions
   - Add income/expense
   - List transactions
   - Filter by date/category
   - Delete/edit transaction

3. Categories
   - Predefined + user-defined categories

4. Balance
   - Auto-calculated from transactions

5. Wishlist
   - Track savings goals

---

## Data Model

### transactions
- id (uuid)
- user_id (uuid)
- amount (numeric)
- type ("income" | "expense")
- category_id (uuid)
- note (text)
- date (timestamp)
- created_at (timestamp)

### categories
- id (uuid)
- user_id (uuid, nullable for default categories)
- name (text)
- icon (text)
- type ("income" | "expense")

### wishlist
- id (uuid)
- user_id (uuid)
- name (text)
- target_amount (numeric)
- current_amount (numeric)
- deadline (timestamp, nullable)

---

## Security (MANDATORY)

Enable Row Level Security (RLS) on all tables.

Policy pattern:
auth.uid() = user_id

Apply for:
- SELECT
- INSERT
- UPDATE
- DELETE

---

## Architecture

### Pattern
Feature-based + layered architecture

lib/
├── features/
│ ├── auth/
│ ├── transactions/
│ ├── categories/
│ └── wishlist/
├── data/
│ ├── models/
│ ├── repositories/
│ └── datasources/
├── core/
│ ├── utils/
│ └── constants/


---

## Data Flow

UI → Riverpod Provider → Repository →  
→ Local DB (Hive)  
→ Sync with Supabase (async)

---

## Sync Strategy

- Write locally first
- Sync to Supabase in background
- Pull remote updates on app start

Conflict strategy:
- Last-write-wins (simple for MVP)

---

## Performance Rules

- Always paginate remote queries
- Avoid fetching full tables
- Cache frequently accessed data locally
- Minimize Supabase egress usage

---

## UX Principles

- Fast input (≤2 taps to add transaction)
- Default values (today’s date, last category)
- Minimal friction
- Offline-first experience

---

## Future Enhancements

- Charts (monthly analytics)
- Recurring transactions
- Multi-device sync improvements
- Export data (CSV)

---

## Non-Goals (for now)

- No complex budgeting system
- No AI predictions
- No multi-currency support
