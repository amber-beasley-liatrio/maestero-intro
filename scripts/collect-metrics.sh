#!/bin/bash
# Collect performance metrics from GitHub Actions workflow runs

set -euo pipefail

OUTPUT_FILE="${1:-docs/viability-report/performance-metrics.json}"

echo "Collecting workflow run metrics..."
echo "Output file: $OUTPUT_FILE"

# Get the 3 most recent successful workflow runs
RUNS=$(gh run list --workflow=main.yml --status=success --limit 3 --json databaseId --jq '.[].databaseId')

if [ -z "$RUNS" ]; then
  echo "Error: No successful workflow runs found"
  exit 1
fi

RUN_COUNT=$(echo "$RUNS" | wc -l | tr -d ' ')
echo "Found $RUN_COUNT successful runs"

# Start JSON array
echo "[" > "$OUTPUT_FILE"

FIRST=true
for RUN_ID in $RUNS; do
  if [ "$FIRST" = false ]; then
    echo "," >> "$OUTPUT_FILE"
  fi
  FIRST=false
  
  echo "  Processing run $RUN_ID..."
  
  # Get detailed run information
  gh run view "$RUN_ID" --json databaseId,displayTitle,conclusion,createdAt,updatedAt,jobs \
    --jq '{
      run_id: .databaseId,
      title: .displayTitle,
      conclusion: .conclusion,
      created_at: .createdAt,
      updated_at: .updatedAt,
      duration_minutes: (((.updatedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 60),
      jobs: [.jobs[] | {
        name: .name,
        conclusion: .conclusion,
        started_at: .startedAt,
        completed_at: .completedAt,
        duration_minutes: (((.completedAt | fromdateiso8601) - (.startedAt | fromdateiso8601)) / 60)
      }]
    }' >> "$OUTPUT_FILE"
done

# Close JSON array
echo "" >> "$OUTPUT_FILE"
echo "]" >> "$OUTPUT_FILE"

echo "✅ Metrics collected successfully: $OUTPUT_FILE"
echo ""
echo "Summary:"
jq -r '.[] | "Run \(.run_id): \(.duration_minutes | floor)min - \(.conclusion)"' "$OUTPUT_FILE"
