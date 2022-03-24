#!/usr/bin/bash

max_pipe_size=$(cat /proc/sys/fs/pipe-max-size)

# Write back twice the data that can be fit in a pipe.
dd if=/dev/zero of=/dev/stdout bs=${max_pipe_size} count=2 \
    2> >( sed 's/\([^,]*\),.*/\1/' >&2 )

exit 0
