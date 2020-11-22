#!/bin/sh

# check if jazzy is indeed accessible
if [[ ! -x "$(command -v jazzy)" ]]; then
    echo "Error: jazzy could not be found - cannot continue"
else
    echo "Jazzy found and is executable - invoking..."
    # execute jazzy
    jazzy
fi

