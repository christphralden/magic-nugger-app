#!/bin/sh
set -e

echo "Running database migrations..."
node db/runner.mjs up

echo "Starting server..."
exec "$@"
