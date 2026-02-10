# Sample Data

Use `activities.csv` as a reference for the expected upload format.

## Column Reference

| Column | Type | Description |
|--------|------|-------------|
| `recorded_at` | ISO 8601 timestamp | When the activity occurred (with timezone) |
| `activity_type` | text | Activity name (e.g., "Running", "Weight Training", "Pool Swimming") |
| `distance_miles` | number | Distance in miles. For swimming, use meters instead. |
| `sets` | integer | Number of sets (strength training) |
| `avg_pace_seconds` | integer | Average pace in seconds per mile |
| `duration_minutes` | integer | Total duration in minutes |
| `calories` | integer | Calories burned |
| `notes` | text | Free-form notes |

All columns except `recorded_at` and `activity_type` are optional -- leave them blank if not applicable.

## Tips

- Export from Apple Health, Google Fit, or Garmin Connect and reformat to match this schema
- The app deduplicates on `(activity_type, recorded_at)` so re-uploading the same file is safe
- After upload, personal records and streaks are automatically recalculated
