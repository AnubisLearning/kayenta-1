#!/bin/bash

PUSHGATEWAY_URL="http://localhost:9091"
JOB_NAME="cpu_metrics"

while true; do
  # Generate baseline value between 10 and 90
  BASELINE_CPU=$(awk -v min=10 -v max=90 'BEGIN{srand(); val=min+rand()*(max-min); printf "%.2f", val}')

  # Calculate canary as the opposite (100 - baseline), capped between 10 and 90
  CANARY_CPU=$(awk -v base=$BASELINE_CPU 'BEGIN{val=100-base; if (val<10) val=10; if (val>90) val=90; printf "%.2f", val}')

  # Push metrics without timestamps
  echo "cpu_usage $BASELINE_CPU" | curl --silent --data-binary @- "$PUSHGATEWAY_URL/metrics/job/$JOB_NAME/instance/baseline"
  echo "cpu_usage $CANARY_CPU"  | curl --silent --data-binary @- "$PUSHGATEWAY_URL/metrics/job/$JOB_NAME/instance/canary"

  echo "[$(date)] Pushed metrics - Baseline: $BASELINE_CPU, Canary: $CANARY_CPU"

  # Wait before next push
  sleep 2
done
