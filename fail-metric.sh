#!/bin/bash

PUSHGATEWAY_URL="http://localhost:9091"
JOB_NAME="cpu_metrics"

CANARY_CPU=10  # Start at minimum value
INCREMENT=1  # Step increase for each cycle
MAX_CANARY_CPU=800

while true; do
  # Generate random baseline CPU usage
  BASELINE_CPU=$(awk -v min=10 -v max=70 'BEGIN{srand(); print min+rand()*(max-min)}')

  # Increase CANARY_CPU gradually
  if [ "$CANARY_CPU" -lt "$MAX_CANARY_CPU" ]; then
    CANARY_CPU=$((CANARY_CPU + INCREMENT))
  fi

  # Push metrics without timestamps
  echo "cpu_usage $BASELINE_CPU" | curl --silent --data-binary @- "$PUSHGATEWAY_URL/metrics/job/$JOB_NAME/instance/baseline"
  echo "cpu_usage $CANARY_CPU"  | curl --silent --data-binary @- "$PUSHGATEWAY_URL/metrics/job/$JOB_NAME/instance/canary"

  echo "[$(date)] Pushed metrics - Baseline: $BASELINE_CPU, Canary: $CANARY_CPU"

  # Wait before next push
  sleep 2
done
