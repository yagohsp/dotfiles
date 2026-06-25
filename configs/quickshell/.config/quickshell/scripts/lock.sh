#!/usr/bin/env bash
printf '%s\n' "$(date +%s%N)" > /tmp/qs-lock.signal
