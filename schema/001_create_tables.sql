-- Health Data Service - Database Schema
-- Run against any PostgreSQL 14+ instance (Timescale Cloud recommended)

-- Create a dedicated schema
CREATE SCHEMA IF NOT EXISTS health;

-- Activities table (daily records)
CREATE TABLE health.activities (
    recorded_at     timestamptz NOT NULL,
    activity_type   text        NOT NULL,
    distance_miles  double precision,   -- miles for most activities, meters for swimming
    sets            integer,
    avg_pace_seconds integer,
    duration_minutes integer,
    calories        integer,
    notes           text
);

CREATE INDEX idx_activities_type_time
    ON health.activities (activity_type, recorded_at);

-- Monthly metrics (historical aggregates)
CREATE TABLE health.monthly_metrics (
    month_start     timestamptz NOT NULL,
    activity_type   text,
    metric_name     text        NOT NULL,
    value           double precision NOT NULL
);

CREATE INDEX idx_monthly_metrics_name_month
    ON health.monthly_metrics (metric_name, month_start);

-- User baselines
CREATE TABLE health.user_baselines (
    id                      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    updated_at              timestamptz DEFAULT now(),
    avg_daily_steps         integer,
    avg_weekly_steps        integer,
    daily_resting_calories  integer,
    daily_active_calories   integer,
    max_heart_rate          integer,
    resting_heart_rate      integer
);

-- Goals
CREATE TABLE health.goals (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    goal_type       text            NOT NULL,   -- 'daily', 'weekly', 'monthly'
    metric_type     text            NOT NULL,   -- 'distance', 'duration', 'calories', 'count'
    activity_type   text,
    target_value    double precision NOT NULL,
    start_date      date            NOT NULL,
    end_date        date,
    is_active       boolean         DEFAULT true,
    created_at      timestamptz     DEFAULT now()
);

-- Personal records
CREATE TABLE health.personal_records (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    activity_type   text            NOT NULL,
    record_type     text            NOT NULL,   -- 'max_distance', 'max_calories', 'max_duration', 'min_pace'
    record_value    double precision NOT NULL,
    achieved_at     timestamptz     NOT NULL,
    created_at      timestamptz     DEFAULT now()
);

-- Activity streaks
CREATE TABLE health.activity_streaks (
    id                  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    activity_type       text,           -- NULL = any activity
    current_streak      integer DEFAULT 0,
    longest_streak      integer DEFAULT 0,
    last_activity_date  date,
    streak_start_date   date,
    updated_at          timestamptz DEFAULT now()
);

-- AI insights
CREATE TABLE health.ai_insights (
    id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    insight_type    text        NOT NULL,
    insight_text    text        NOT NULL,
    period_start    date,
    period_end      date,
    is_dismissed    boolean     DEFAULT false,
    created_at      timestamptz DEFAULT now()
);
