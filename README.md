# benshalomlab_spikesorter_shifter

A minimal, **NERSC Shifter-friendly** wrapper image around the lab-maintained spikesorting runtime:

- Base image: `mandarmp/benshalomlab_spikesorter:latest`
- Adds: Maxwell HDF5 plugin (`HDF5_PLUGIN_PATH=/opt/maxwell_hdf5_plugin/Linux`)

This repo exists so we can publish a clearly tagged Docker image that NERSC Shifter can pull and cache.

## Build + push (local PC)

1) Pick a new tag (avoid reusing tags; Shifter caching is painful):

- `TAG=v1`

2) Build + push (builds `linux/amd64` by default, important on Apple Silicon):

- `docker login`
- `TAG=v1 ./scripts/build_and_push.sh`

Optional overrides:

- `IMAGE=adammwea/benshalomlab_spikesorter_shifter TAG=v1 PLATFORM=linux/amd64 ./scripts/build_and_push.sh`

3) Sanity check:

- `docker run --rm --entrypoint python3 adammwea/benshalomlab_spikesorter_shifter:v1 -c "import h5py; print('h5py OK')"`
- `docker run --rm --entrypoint /bin/bash adammwea/benshalomlab_spikesorter_shifter:v1 -lc 'echo $HDF5_PLUGIN_PATH && ls -1 "$HDF5_PLUGIN_PATH" | head'`

If your tag is built from this repo after Jan 2026, it clears the inherited base ENTRYPOINT
so `docker run ... bash -lc '...'` behaves normally (recommended for Shifter).

## Pull into Shifter (NERSC)

On a Perlmutter login node:

- `shifterimg pull docker:adammwea/benshalomlab_spikesorter_shifter:v1`
- `shifterimg images | grep benshalomlab_spikesorter_shifter || true`

Allocate an interactive GPU node using the image:

- `salloc -A <YOUR_ALLOCATION> -q interactive -C gpu -t 04:00:00 --nodes=1 --gpus=1 --image=adammwea/benshalomlab_spikesorter_shifter:v1`

## Notes

- This image intentionally stays small in scope; the lab’s base image should contain the SpikeInterface/Kilosort runtime.
- The Maxwell plugin is included for compressed `.h5` recordings.
