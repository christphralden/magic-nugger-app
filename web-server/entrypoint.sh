#!/bin/sh
set -e

echo "Running database migrations..."
node /app/db/runner.mjs up

echo "Starting server..."
exec "$@"
