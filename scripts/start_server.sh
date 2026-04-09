#!/bin/bash
echo "Starting DOVE6 NVR Server..."
cd "$(dirname "$0")/../server"
go run .
