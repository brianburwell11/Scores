#!/bin/bash

cp githooks/* .git/hooks/
cp githooks/.env .git/hooks/
chmod +x .git/hooks/*
echo "Hooks installed successfully!"
