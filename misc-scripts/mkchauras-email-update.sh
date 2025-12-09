#! /bin/bash
set -x

/bin/lei up --all 2>&1 | tee /tmp/lei.log
/bin/mbsync -Va 2>&1 | tee /tmp/mbsync.log
