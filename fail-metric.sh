#!/bin/bash

PUSHGATEWAY_URL="http://localhost:9091"
JOB_NAME="cpu_metrics"

while true; do
  # Baseline: tightly clustered around low values (10-15)
  BASELINE_CPU=$(awk -v min=10 -v max=15 'BEGIN{srand(); val=min+rand()*(max-min); printf "%.2f", val}')

  # Canary: widely varied and higher (70-100)
  CANARY_CPU=$(awk -v min=70 -v max=100 'BEGIN{srand(); val=min+rand()*(max-min); printf "%.2f", val}')

  # Push metrics
  echo "cpu_usage $BASELINE_CPU" | curl --silent --data-binary @- "$PUSHGATEWAY_URL/metrics/job/$JOB_NAME/instance/baseline"
  echo "cpu_usage $CANARY_CPU"  | curl --silent --data-binary @- "$PUSHGATEWAY_URL/metrics/job/$JOB_NAME/instance/canary"

  echo "[$(date)] Pushed metrics - Baseline: $BASELINE_CPU, Canary: $CANARY_CPU"

  sleep 2
done
