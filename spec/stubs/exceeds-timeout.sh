#!/usr/bin/bash

timeout=$1
echo "Sent prior to timeout of $timeout"
sleep $(( $timeout + 1 ))
echo "Sent after to timeout of $timeout"

exit 0
