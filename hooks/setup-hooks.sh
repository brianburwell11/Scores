#!/bin/bash

cp hooks/* .git/hooks/
cp hooks/.env .git/hooks/
chmod +x .git/hooks/*

# Install qpdf if it's not installed
if ! command -v qpdf &> /dev/null; then
    echo "Installing qpdf..."
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install qpdf
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        # Windows
        echo "On Windows, please:"
        echo "1. Download QPDF from https://github.com/qpdf/qpdf/releases"
        echo "2. Extract the downloaded zip file"
        echo "3. Add the extracted bin directory to your system PATH"
        echo "4. Restart your terminal"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        sudo apt-get install qpdf
    else
        echo "Unsupported operating system. Please install qpdf manually."
    fi
fi

echo 
echo "Hooks installed successfully!"
