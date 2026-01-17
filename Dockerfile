# Shifter-ready wrapper image for NERSC Perlmutter
# Base runtime maintained by the lab:
#   https://hub.docker.com/r/mandarmp/benshalomlab_spikesorter
FROM mandarmp/benshalomlab_spikesorter:latest

# Keep changes minimal. We only add the Maxwell HDF5 plugin and ensure pip tooling is usable.
RUN python3 -m pip install --upgrade pip setuptools wheel

# Maxwell HDF5 plugin (needed to read some MaxWell-compressed .h5 recordings)
COPY maxwell_hdf5_plugin /opt/maxwell_hdf5_plugin
ENV HDF5_PLUGIN_PATH=/opt/maxwell_hdf5_plugin/Linux

WORKDIR /workspace
# The base image defines an ENTRYPOINT (/entrypoint.sh) that auto-updates MEA_Analysis
# and immediately runs run_pipeline_driver.py. For NERSC Shifter and interactive work
# we want a predictable shell by default, so clear the inherited ENTRYPOINT.
ENTRYPOINT []
CMD ["bash"]
