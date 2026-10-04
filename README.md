# Crowzy Finance

Offline-first personal finance app built with Flutter. Track income and
expenses, manage categories and wishlist goals, view monthly reports, get
spending/income alerts, and use an AI analyzer to log transactions from text
and ask questions about your spending.

There is no custom backend: the app talks to [Supabase](https://supabase.com)
directly (Postgres with RLS, Auth, Edge Functions). State is Riverpod; local
storage is Hive.

## Getting started

Requires Flutter (Dart SDK `^3.11.4`).

```bash
flutter pub get
flutter run
```

The Supabase URL and publishable key are in
`lib/core/constants/supabase_constants.dart`. To point at your own project,
change them there.

### Accounts and transfers

Every income or expense belongs to an account (Bank, E-wallet or Cash). Each
user gets a default Cash account, created on first use, and a transaction with
no account counts as being on it, so older data needs no migration. A transfer
moves money between two accounts; it is stored on its own, never as income or
expense, so reports, budgets, alerts and the AI never see it. An optional fee is
recorded as an ordinary expense (category Fees) linked to its transfer, which is
the only part that counts as spending. The Home balance is the sum of all
accounts, archived ones included.

### Look and feel

The app is dark-only (bottle-green, ivory and brass). Titles and amounts use
Cormorant Garamond, body text Hanken Grotesk, and receipt screens Courier
Prime. The fonts are bundled in `assets/google_fonts/` and runtime fetching is
turned off, so the app renders the same offline. Colours, type and motion
tokens live in `lib/core/theme/` (`AppColors`, `AppText`, `AppMotion`); motion
respects the system's reduced-motion setting.

### Code generation

Models (freezed/json_serializable) and providers (riverpod_generator) use
generated files, which are committed. After changing a `@freezed` model or a
`@riverpod` provider:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Checks

```bash
flutter analyze
flutter test
```

CI (`.github/workflows/ci.yml`) runs both, and also fails if the generated
code is out of date.

## Supabase setup

Migrations live in `supabase/migrations/`:

1. `20260701000000_base_schema.sql` — `categories`, `transactions`,
   `wishlist`, RLS policies, and the seeded default categories. The column
   types were inferred from the Dart models; diff against an existing project
   (`supabase db diff`) before applying it there.
2. `20260724000000_alerts.sql` — `alerts` table, the `evaluate_alerts()`
   rule function, and a daily pg_cron job.
3. `20261003000000_budgets.sql` — the optional per-category `budgets` table
   (with RLS).
4. `20261003000100_budget_and_positive_alerts.sql` — adds the `budget_limit`,
   `income_received` and `goal_on_track` alert rules to `evaluate_alerts()`.

5. `20261004000000_accounts_and_transfers.sql` — the `accounts` and
   `transfers` tables (with RLS), `account_id` and `transfer_id` on
   `transactions`, the default "Fees" category, and a change to
   `evaluate_alerts()` so a transfer's fee never raises a category-spike alert.

**Deploy order differs between the two groups:**

- Migrations 3 and 4: ship the app update **before** running them. An older app
  build cannot parse the new alert types.
- Migration 5: run it **before** shipping the app update. The new app sends
  `account_id` and `transfer_id` with every transaction, so the columns must
  exist first. Older app builds are unaffected, since the columns are nullable
  and an upsert that leaves them out keeps what is there.

```bash
supabase link --project-ref <ref>
supabase db push
```

### Edge Functions

`parse-transaction`, `parse-correction`, `chat-qa`, `passive-insights` and
`generate-alerts` live in `supabase/functions/`.

```bash
supabase secrets set ANTHROPIC_API_KEY=<key>   # AI functions
supabase secrets set CRON_SECRET=<random>      # generate-alerts
supabase functions deploy <name>
```

The alerts cron job reads the same secret from Supabase Vault. Run once in
the SQL editor, using the same value as above:

```sql
select vault.create_secret('<same-random-value>', 'cron_secret');
```

`generate-alerts` is the only function with `verify_jwt = false`; it is
authenticated by the `x-cron-secret` header instead (see
`supabase/config.toml`). The cron migration hardcodes the project's
function URL, so update it when using a different project.

## How sync works

Writes go to Hive first and are flagged `isSynced: false`. `SyncService`
(`lib/core/sync/sync_service.dart`) pushes dirty rows to Supabase, then pulls
changes since the last sync per table. Newest `updated_at` wins; deletes are
soft. Alerts are server-generated and pull-only.
