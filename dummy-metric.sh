#!/bin/bash

PUSHGATEWAY_URL="http://localhost:9091"
JOB_NAME="cpu_metrics"

while true; do
  # Generate random CPU usage values
  CANARY_CPU=$(awk -v min=20 -v max=80 'BEGIN{srand(); print min+rand()*(max-min)}')
  BASELINE_CPU=$(awk -v min=10 -v max=70 'BEGIN{srand(); print min+rand()*(max-min)}')

  # Push metrics without timestamps
  echo "cpu_usage $BASELINE_CPU" | curl --silent --data-binary @- "$PUSHGATEWAY_URL/metrics/job/$JOB_NAME/instance/baseline"
  echo "cpu_usage $CANARY_CPU"  | curl --silent --data-binary @- "$PUSHGATEWAY_URL/metrics/job/$JOB_NAME/instance/canary"

  echo "[$(date)] Pushed metrics - Baseline: $BASELINE_CPU, Canary: $CANARY_CPU"

  # Wait before next push
  sleep 2
done
