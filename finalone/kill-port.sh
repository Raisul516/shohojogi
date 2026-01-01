#!/bin/bash

# Script to kill processes on ports 5050 and 3000

PORT_5050=$(lsof -ti:5050)
PORT_3000=$(lsof -ti:3000)

if [ ! -z "$PORT_5050" ]; then
    echo "Killing process on port 5050 (PID: $PORT_5050)..."
    kill -9 $PORT_5050
    echo "✓ Port 5050 is now free"
else
    echo "Port 5050 is already free"
fi

if [ ! -z "$PORT_3000" ]; then
    echo "Killing process on port 3000 (PID: $PORT_3000)..."
    kill -9 $PORT_3000
    echo "✓ Port 3000 is now free"
else
    echo "Port 3000 is already free"
fi

echo ""
echo "You can now start your servers:"
echo "  Backend:  cd backend && npm start"
echo "  Frontend: cd worker-calling-frontend && npm start"

