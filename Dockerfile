FROM openjdk:8-jdk-stretch

# INSTALL MINICONDA
ARG BUILD_DATE
ARG MINICONDA_VERSION=3
ARG MINICONDA_RELEASE=py37_4.8.2
ARG MINICONDA_CHECKSUM=957d2f0f0701c3d1335e3b39f235d197837ad69a944fa6f5d8ad2c686b69df3b
ARG PYTHON_VERSION
ARG DATABRICKS_CONNECT_VERSION

ENV PATH="/opt/miniconda${MINICONDA_VERSION}/bin:${PATH}"
ENV MLFLOW_TRACKING_URI="databricks"

RUN set -x && \
    apt-get update && \
    apt-get install -y curl bzip2 build-essential && \
    curl -s -L --url "https://repo.continuum.io/miniconda/Miniconda${MINICONDA_VERSION}-${MINICONDA_RELEASE}-Linux-x86_64.sh" --output /tmp/miniconda.sh && \
    echo "${MINICONDA_CHECKSUM}  /tmp/miniconda.sh" | shasum -a 256 -c && \
    bash /tmp/miniconda.sh -b -f -p "/opt/miniconda${MINICONDA_VERSION}" && \
    rm /tmp/miniconda.sh && \
    apt-get purge -y bzip2 && \
    apt-get clean && \
    conda config --set auto_update_conda true && \
    if [ "$MINICONDA_VERSION" = "2" ]; then\
        conda install -y futures;\
    fi && \
    if [ "$MINICONDA_RELEASE" = "latest" ]; then\
        conda update conda -y --force;\
    fi && \
    if [ -n "$PYTHON_VERSION" ]; then\
        conda install python=$PYTHON_VERSION -y --force;\
    fi && \
    conda clean -tipsy && \
    pip install --upgrade pip && \
    find /opt/miniconda${MINICONDA_VERSION} -depth \( \( -type d -a \( -name test -o -name tests \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) | xargs rm -rf && \
    echo "PATH=/opt/miniconda${MINICONDA_VERSION}/bin:\${PATH}" > /etc/profile.d/miniconda.sh && \
    echo "source /etc/profile.d/miniconda.sh" >> ~/.bashrc

# Copy and setup utility scripts to authenticate agains databricks from keyvault
COPY scripts/ /utils
RUN chmod +x -R /utils && \
    pip install -r /utils/requirements.txt

# Install databricks-cli
RUN pip install databricks-cli mlflow databricks-connect==$DATABRICKS_CONNECT_VERSION && \
    echo "{}" > ~/.databricks-connect

# Install utilities that can be used in ci pipelines
RUN apt-get update -y && \
    apt-get install -y jq && \
    pip install yq

