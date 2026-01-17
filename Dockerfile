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

# Provide our own entrypoint so we can control which MEA_Analysis repo/branch is used.
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Defaults can be overridden at runtime via environment variables.
ENV MEA_ANALYSIS_REPO_URL=https://github.com/roybens/MEA_Analysis.git
ENV MEA_ANALYSIS_BRANCH=dev_branch_aw_2
ENV MEA_ANALYSIS_DIR=/MEA_Analysis
ENV MEA_ANALYSIS_AUTO_UPDATE=1
ENV MEA_ANALYSIS_AUTO_RUN=1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
