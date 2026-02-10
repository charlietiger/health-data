# Database Schema

## Setup

Run the SQL file against your PostgreSQL database:

```bash
psql "$DATABASE_URL" -f 001_create_tables.sql
```

Or, if using Drizzle ORM with the app, run:

```bash
npm run db:push
```

## Entity Relationship

```
activities ──────────────── (core data, queried by all features)
    │
    ├── personal_records    (derived: best stats per activity type)
    ├── activity_streaks    (derived: consecutive day counts)
    ├── monthly_metrics     (derived: pre-aggregated monthly data)
    └── goals               (user-defined targets, progress calculated from activities)

user_baselines ──────────── (standalone: personal reference stats)
ai_insights ─────────────── (standalone: stored AI coaching outputs)
```

## Tables

### `health.activities`
The core table. Every workout or activity is a row. No primary key constraint -- deduplication is handled at the application layer using `(activity_type, recorded_at)` pairs.

### `health.monthly_metrics`
Optional pre-aggregated monthly statistics. Useful for fast historical queries without scanning the full activities table.

### `health.user_baselines`
Single-row table holding the user's personal reference numbers (step counts, calorie targets, heart rate zones).

### `health.goals`
User-created fitness targets. Each goal specifies a time period (daily/weekly/monthly), a metric (distance, duration, calories, or activity count), and a target value. Progress is calculated in real-time from the activities table.

### `health.personal_records`
Derived from activities. Stores the best value for each `(activity_type, record_type)` pair. Record types: `max_distance`, `max_duration`, `max_calories`, `min_pace`. Recalculated on CSV upload or manually via the API.

### `health.activity_streaks`
Derived from activities. Tracks consecutive days of activity. A row with `activity_type = NULL` represents the overall streak across all activity types.

### `health.ai_insights`
Stores AI-generated coaching insights so they can be reviewed later. Each insight has a type, text content, and the period it covers.
