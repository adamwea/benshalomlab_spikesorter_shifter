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
- `docker run --rm adammwea/benshalomlab_spikesorter_shifter:v1 bash -lc 'echo $HDF5_PLUGIN_PATH && ls -1 "$HDF5_PLUGIN_PATH" | head'`

## Choosing the MEA_Analysis version

This image uses an entrypoint that can auto-update and run Mandar’s driver. You can control
which MEA_Analysis repo/branch it uses via env vars:

- `MEA_ANALYSIS_REPO_URL` (default: `https://github.com/roybens/MEA_Analysis.git`)
- `MEA_ANALYSIS_BRANCH` (default: `dev_branch_aw_2`)

Example (run pipeline using your branch explicitly):

- `docker run --rm -e MEA_ANALYSIS_BRANCH=dev_branch_aw_2 adammwea/benshalomlab_spikesorter_shifter:v1 python3 /MEA_Analysis/IPNAnalysis/run_pipeline_driver.py -h`

To disable auto-update / auto-run behavior and just get a shell:

- `docker run --rm -e MEA_ANALYSIS_AUTO_UPDATE=0 -e MEA_ANALYSIS_AUTO_RUN=0 adammwea/benshalomlab_spikesorter_shifter:v1 bash`

## Pull into Shifter (NERSC)

On a Perlmutter login node:

- `shifterimg pull docker:adammwea/benshalomlab_spikesorter_shifter:v1`
- `shifterimg images | grep benshalomlab_spikesorter_shifter || true`

Allocate an interactive GPU node using the image:

- `salloc -A <YOUR_ALLOCATION> -q interactive -C gpu -t 04:00:00 --nodes=1 --gpus=1 --image=adammwea/benshalomlab_spikesorter_shifter:v1`

## Notes

- This image intentionally stays small in scope; the lab’s base image should contain the SpikeInterface/Kilosort runtime.
- The Maxwell plugin is included for compressed `.h5` recordings.
