#!/bin/bash

# Find Puma process ID
PID=$(ps aux | grep puma | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
  echo "No Puma process found."
else
  echo "Stopping Puma (PID: $PID)..."
  kill -9 $PID
  echo "Puma stopped."
fi