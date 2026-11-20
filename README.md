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
3. `20261005000000_accounts_archive.sql` — adds `is_archived` to `accounts`
   (additive, safe to run twice).

**These files are a partial record of the live project.** The project in use was
built with more migrations than this repository holds: `accounts`,
`transfer_group_id` on `transactions`, `budgets`, the *Transfer In* and
*Transfer Out* categories, `format_rp()`, the `budget_exceeded` alert rule,
recurring transactions and device tokens. The app is written against that live
schema, so **do not run `supabase db push`** against it: the migration history
there does not match this directory. Run the one new statement by hand instead,
in the dashboard's SQL editor, once, before releasing the app version that
archives accounts. Older builds are unaffected by it.

For a brand-new project, `supabase db pull` from the live one gives a complete
set of migrations.

### How accounts and transfers are stored

Accounts are `bank`, `e_wallet` or `cash`, with an `initial_balance`, an optional
`is_main` flag (the default source for new transactions and transfers) and, since
the migration above, `is_archived`. A transaction with no `account_id` is
*unassigned*; it still counts in the total.

A transfer has no table of its own. It is two ordinary transactions that share a
`transfer_group_id` and the same date and note: an expense in the *Transfer Out*
category on the source account and an income in *Transfer In* on the destination.
The app pairs them back into one transfer for display. Because the two legs are
income and expense in the data, reports, budgets, alerts and the AI contexts all
leave them out. A transfer's optional fee is a separate, ordinary expense in the
user's *Admin Fee* category, so it counts as spending.

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
