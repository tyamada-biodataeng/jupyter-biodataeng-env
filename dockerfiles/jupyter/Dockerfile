FROM condaforge/miniforge3:26.3.2-3

ARG DIR_WORK
WORKDIR ${DIR_WORK}/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++ \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG ENV_YAML
COPY ${ENV_YAML} ${DIR_WORK}/
ARG VENV
RUN mamba update -y -c conda-forge mamba && \
    mamba env create -f ${ENV_YAML} && \
    mamba run -n ${VENV} pip install --no-cache-dir --upgrade pip && \
    mamba run -n ${VENV} pip cache purge && \
    mamba clean -a -y

ARG REQ_TXT
COPY ${REQ_TXT} ${DIR_WORK}/
RUN mamba run -n ${VENV} pip install --no-cache-dir -r ${REQ_TXT} && \
    mamba run -n ${VENV} pip cache purge && \
    mamba clean -a -y

USER ubuntu

CMD ["mamba", "run", "-n", "${VENV}", "/bin/bash"]
