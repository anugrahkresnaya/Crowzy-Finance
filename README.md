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
