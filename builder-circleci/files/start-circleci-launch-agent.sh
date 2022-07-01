#!/bin/bash
set -e

if [ -z "${LAUNCH_AGENT_API_AUTH_TOKEN}" ]; then
  echo "No API token supplied; exiting"
  exit 1
fi

if [[ -z "${LAUNCH_AGENT_RUNNER_NAME}" ]]; then
  LAUNCH_AGENT_RUNNER_NAME=$(hostname)
  export LAUNCH_AGENT_RUNNER_NAME
fi

exec /opt/circleci/circleci-launch-agent
