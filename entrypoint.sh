#!/bin/sh

set -e

echo "Building the site with Qgoda..."
qgoda --verbose build

echo "pwd:"
pwd

echo "ls -R"
ls -R

echo "/home/runner"
ls -R /home/runner
