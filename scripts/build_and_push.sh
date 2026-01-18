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
#   PULL=1            # pull updated base image (default: 1)
#   NO_CACHE=0        # set to 1 to disable build cache

IMAGE="${IMAGE:-adammwea/benshalomlab_spikesorter_shifter}"
TAG="${TAG:?Set TAG, e.g. TAG=v1}"
PLATFORM="${PLATFORM:-linux/amd64}"
PULL="${PULL:-1}"
NO_CACHE="${NO_CACHE:-0}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "Building $IMAGE:$TAG (platform=$PLATFORM, pull=$PULL, no_cache=$NO_CACHE)"

build_args=(
	build
	--platform="$PLATFORM"
	-t "$IMAGE:$TAG"
)

if [[ "$PULL" == "1" ]]; then
	build_args+=(--pull)
fi

if [[ "$NO_CACHE" == "1" ]]; then
	build_args+=(--no-cache)
fi

build_args+=(.)

docker "${build_args[@]}"

echo "Pushing $IMAGE:$TAG"
push_out="$(mktemp)"
docker push "$IMAGE:$TAG" | tee "$push_out"

# Docker prints a line like: "latest: digest: sha256:... size: ..."
digest="$(grep -Eo 'digest: sha256:[0-9a-f]+' "$push_out" | tail -n1 | awk '{print $2}' || true)"
rm -f "$push_out"

if [[ -n "$digest" ]]; then
	echo "Pushed digest: $digest"
	echo "Immutable reference (preferred for Shifter when supported):"
	echo "  docker:$IMAGE@$digest"
fi

echo "Done. Next on NERSC:"
echo "  shifterimg pull docker:$IMAGE:$TAG"
echo "  # (optional) verify: shifterimg images | grep benshalomlab_spikesorter_shifter || true"
