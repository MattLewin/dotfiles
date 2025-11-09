#!/usr/bin/env fish

# Ping every 5 seconds and highlight spikes over 100 ms
ping -i 5 -D google.com | awk -v thr=100 '
/^\[[0-9]+\.[0-9]+\]/ {
  if (match($0, /^\[([0-9]+)\./, t) && match($0, /time=([0-9.]+) ms/, m)) {
    ts = t[1] + 0
    ms = m[1] + 0
    human = strftime("%Y-%m-%d %H:%M:%S", ts)
    if (ms > thr)
      printf("\033[31m[%s] %.1f ms\033[0m\n", human, ms)
    else
      printf("[%s] %.1f ms\n", human, ms)
    fflush()
    next
  }
}
{ print; fflush() }'
