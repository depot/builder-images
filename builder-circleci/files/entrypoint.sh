#!/bin/bash
set -eu

if [[ "$#" == 0 ]]; then
  exec multirun "/start-dockerd.sh" "/start-circleci-launch-agent.sh"
fi

exec "$@"
