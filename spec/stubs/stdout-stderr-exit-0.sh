#!/usr/bin/bash

echo "This is the expected standard out."
echo "This is the expected standard error." >&2
echo "Standard error is interleaved with standard out." >&2
echo "It is over multiple lines."
echo "It is also over multiple lines." >&2

exit 0
