#!/usr/bin/env bash
set -euo pipefail

# Build + push this Shifter-ready image from your local machine.
#
# Usage:
#   TAG=v1 ./scripts/build_and_push.sh
#
# Optional env:
#   IMAGE=adammwea/benshalomlab_spikesorter_shifter
#   PLATFORM=linux/amd64

IMAGE="${IMAGE:-adammwea/benshalomlab_spikesorter_shifter}"
TAG="${TAG:?Set TAG, e.g. TAG=v1}"
PLATFORM="${PLATFORM:-linux/amd64}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "Building $IMAGE:$TAG (platform=$PLATFORM)"
docker build --platform="$PLATFORM" -t "$IMAGE:$TAG" .

echo "Pushing $IMAGE:$TAG"
docker push "$IMAGE:$TAG"

echo "Done. Next on NERSC:"
echo "  shifterimg pull docker:$IMAGE:$TAG"
