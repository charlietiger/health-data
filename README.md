# Health Data Service

A full-stack personal fitness and health tracking application built with Next.js, tRPC, Drizzle ORM, and PostgreSQL (TimescaleDB). Includes AI-powered coaching insights via the Claude API.

## Features

- **Dashboard** -- Real-time stats with charts (daily/weekly/monthly/quarterly/annual views)
- **CSV Upload** -- Bulk import activity data from spreadsheets
- **Goals** -- Create and track daily, weekly, and monthly fitness targets
- **Personal Records** -- Automatically tracks your bests (distance, duration, calories, pace)
- **Activity Streaks** -- Consecutive-day tracking with calendar heatmap
- **AI Insights** -- Claude-powered weekly/monthly summaries, trend analysis, and a Q&A coach
- **Reports** -- Weekly and monthly breakdowns with period comparisons

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | [Next.js 15](https://nextjs.org/) (App Router, Turbopack) |
| API | [tRPC 11](https://trpc.io/) with [Zod](https://zod.dev/) validation |
| ORM | [Drizzle ORM](https://orm.drizzle.team/) |
| Database | PostgreSQL on [Timescale Cloud](https://www.timescale.com/cloud) |
| UI | [Tailwind CSS 4](https://tailwindcss.com/), [Recharts](https://recharts.org/) |
| AI | [Anthropic Claude API](https://docs.anthropic.com/) |
| CSV Parsing | [PapaParse](https://www.papaparse.com/) |
| Deployment | [Vercel](https://vercel.com/) |

## Architecture

```
src/
├── app/                    # Next.js App Router pages
│   ├── page.tsx            # Dashboard (main stats + charts)
│   ├── goals/              # Goal tracking
│   ├── heart-rate/         # Heart rate data
│   ├── insights/           # AI coaching insights + Q&A
│   ├── records/            # Personal records
│   ├── reports/            # Weekly/monthly reports
│   ├── settings/           # User baselines configuration
│   ├── streaks/            # Activity streaks + calendar heatmap
│   └── upload/             # CSV bulk import
├── components/             # Shared React components
├── server/
│   ├── api/
│   │   ├── trpc.ts         # tRPC context and procedures
│   │   ├── root.ts         # Router registry
│   │   └── routers/
│   │       ├── health.ts   # Activities, dashboard stats, baselines, bulk upload
│   │       ├── goals.ts    # Goal CRUD + progress calculation
│   │       ├── records.ts  # Personal records tracking
│   │       ├── streaks.ts  # Streak calculation + calendar heatmap data
│   │       ├── insights.ts # AI insight generation + Q&A
│   │       └── reports.ts  # Weekly/monthly summaries + period comparison
│   ├── db/
│   │   ├── index.ts        # Database connection (postgres.js + Drizzle)
│   │   └── schema.ts       # Drizzle schema (all 7 tables)
│   └── lib/
│       └── claude.ts       # Anthropic Claude integration
├── trpc/                   # tRPC client setup (React Query)
├── env.js                  # Environment validation (t3-env)
└── styles/
    └── globals.css         # Tailwind + custom neon theme
```

## Database Schema

The app uses a dedicated PostgreSQL schema called `health` with 7 tables. See [`schema/`](./schema/) for the full SQL and a diagram.

| Table | Purpose |
|-------|---------|
| `activities` | Daily activity records (type, distance, duration, calories, pace, notes) |
| `monthly_metrics` | Pre-aggregated monthly stats |
| `user_baselines` | Personal baseline stats (steps, calories, heart rate) |
| `goals` | Fitness targets (daily/weekly/monthly) |
| `personal_records` | Best-ever stats per activity type |
| `activity_streaks` | Consecutive day tracking per activity type |
| `ai_insights` | Stored AI-generated coaching insights |

## Getting Started

### Prerequisites

- [Node.js 20+](https://nodejs.org/)
- A PostgreSQL database (we recommend [Timescale Cloud](https://console.cloud.timescale.com/) -- free tier available)
- An [Anthropic API key](https://console.anthropic.com/) (optional, for AI insights)

### 1. Clone and install

```bash
git clone https://github.com/charlietiger/health-data.git
cd health-data
npm install
```

### 2. Create your database

Create a Timescale Cloud service (or any PostgreSQL instance) and note the connection string.

Then create the schema and tables:

```bash
psql "$DATABASE_URL" -f schema/001_create_tables.sql
```

Or push via Drizzle (once your `.env` is configured):

```bash
npm run db:push
```

### 3. Configure environment

```bash
cp .env.example .env
```

Edit `.env` with your values:

```
DATABASE_URL=postgresql://user:password@host:port/dbname?sslmode=require
ANTHROPIC_API_KEY=sk-ant-...   # Optional: enables AI insights
```

### 4. Run locally

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

### 5. Load data

Navigate to `/upload` in the app and import a CSV file. See [`sample-data/`](./sample-data/) for the expected format.

## CSV Format

The upload page accepts CSV files with these columns:

```csv
recorded_at,activity_type,distance_miles,sets,avg_pace_seconds,duration_minutes,calories,notes
2025-01-15T08:30:00Z,Running,3.1,,480,30,320,Morning run
2025-01-15T17:00:00Z,Weight Training,,4,,45,250,Upper body
2025-01-16T07:00:00Z,Pool Swimming,1500,,,40,280,Laps (distance in meters for swimming)
```

**Notes:**
- `recorded_at` -- ISO 8601 timestamp
- `distance_miles` -- Distance in miles (or meters for swimming activities)
- `sets` -- Number of sets (for strength training)
- `avg_pace_seconds` -- Average pace in seconds per mile
- `duration_minutes` -- Duration in minutes
- Empty fields are fine -- leave blank for non-applicable columns

## API Reference

All API endpoints are type-safe tRPC procedures. Access them via the React hooks or the tRPC client.

### `health` router
| Procedure | Type | Description |
|-----------|------|-------------|
| `getActivities` | query | Fetch activities with date/type filters |
| `getDashboardStats` | query | Aggregated stats by period (daily/weekly/monthly/quarterly/annual) |
| `getMonthlyMetrics` | query | Historical monthly aggregates |
| `getBaselines` | query | Get user baseline stats |
| `updateBaselines` | mutation | Update baseline stats |
| `bulkInsertActivities` | mutation | Bulk insert from CSV (deduplicates, auto-updates records + streaks) |
| `bulkInsertMonthlyMetrics` | mutation | Bulk insert monthly metrics |
| `getActivityTypes` | query | List distinct activity types |

### `goals` router
| Procedure | Type | Description |
|-----------|------|-------------|
| `create` | mutation | Create a new goal |
| `getActive` | query | Get active goals with live progress calculation |
| `getHistory` | query | Get archived/completed goals |
| `update` | mutation | Update goal target or status |
| `delete` | mutation | Delete a goal |

### `records` router
| Procedure | Type | Description |
|-----------|------|-------------|
| `getAll` | query | All personal records, grouped by activity |
| `getByActivity` | query | Records for a specific activity type |
| `checkAndUpdate` | mutation | Check if an activity sets a new record |
| `recalculateAll` | mutation | Recalculate all records from activity history (last 2 years) |

### `streaks` router
| Procedure | Type | Description |
|-----------|------|-------------|
| `getCurrent` | query | Current streak info for an activity type |
| `getAll` | query | All streaks |
| `getCalendarData` | query | Daily activity counts for heatmap (by year) |
| `updateStreaks` | mutation | Recalculate streaks from activity data |
| `initializeAll` | mutation | Initialize streaks for all activity types |

### `insights` router
| Procedure | Type | Description |
|-----------|------|-------------|
| `generate` | mutation | Generate an AI insight (weekly/monthly summary, motivation, trends, recommendation) |
| `getRecent` | query | Fetch recent insights |
| `dismiss` | mutation | Dismiss an insight |
| `askQuestion` | mutation | Ask the AI coach a question about your fitness data |

### `reports` router
| Procedure | Type | Description |
|-----------|------|-------------|
| `getWeeklySummary` | query | Full weekly breakdown (daily + by activity) |
| `getMonthlySummary` | query | Full monthly breakdown (weekly + by activity) |
| `comparePeriods` | query | Compare stats between two arbitrary date ranges |

## Deployment

### Vercel

1. Push your code to GitHub
2. Import the repo in [Vercel](https://vercel.com/new)
3. Add environment variables (`DATABASE_URL`, optionally `ANTHROPIC_API_KEY`)
4. Deploy

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `ANTHROPIC_API_KEY` | No | Enables AI insights and coaching Q&A |
| `NODE_ENV` | No | `development`, `test`, or `production` |

## Customization Ideas

- Add authentication (NextAuth.js, Clerk, etc.)
- Connect to Apple Health / Google Fit via their APIs
- Add notification reminders for streak maintenance
- Build a mobile app with React Native using the same tRPC API
- Add more chart types (line charts for trends over time)
- Integrate with wearable device APIs (Garmin, Fitbit, Whoop)

## License

MIT
