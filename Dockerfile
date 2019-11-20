# Start with the a minmal jupyter notebook
FROM jupyter/minimal-notebook

# Activate the 'root' user
USER root

RUN apt-get update && \
    apt-get install -yq --no-install-recommends pkg-config gnupg software-properties-common && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add - && \
    apt-add-repository "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-6.0 main" && \
    apt-get update && \
    apt-get install -yq --no-install-recommends clang-6.0 gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Activate the 'joyvan' user
USER $NB_UID

# Install xeus-calling
RUN conda install --yes \
    -c QuantStack \
    -c conda-forge \
    xeus-cling && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR

# Disable authentication
RUN mkdir -p .jupyter
RUN echo "" >> ~/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py