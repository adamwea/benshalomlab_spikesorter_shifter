#!/usr/bin/env bash
set -euo pipefail

# Print the commands to run on NERSC after pushing a new tag.
# Usage:
#   TAG=v1 ./scripts/shifter_pull_commands.sh

IMAGE="${IMAGE:-adammwea/benshalomlab_spikesorter_shifter}"
TAG="${TAG:?Set TAG, e.g. TAG=v1}"

cat <<EOF
shifterimg pull docker:$IMAGE:$TAG
shifterimg images | grep "benshalomlab_spikesorter_shifter" || true

# Interactive GPU allocation using that image:
salloc -A <YOUR_ALLOCATION> -q interactive -C gpu -t 04:00:00 --nodes=1 --gpus=1 --image=docker:$IMAGE:$TAG

# After allocation, a quick sanity check that the image is actually active:
# (If you see Python 3.6 + no pip here, the container is NOT being applied.)
srun --ntasks=1 --cpus-per-task=1 --gpus=1 --image=docker:$IMAGE:$TAG /bin/sh -c 'command -v python3 && python3 -V && (python3 -m pip -V || true)'
EOF
