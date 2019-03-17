#!/bin/bash
set -e
cd /home/app/cypress
exec /sbin/setuser app node /home/app/js-ecqm-engine/bin/rabbit_worker.js >>log/js-ecqm-engine.log 2>&1
