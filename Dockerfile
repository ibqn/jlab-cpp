# Start with the a minmal jupyter notebook
FROM jupyter/minimal-notebook

# Activate the 'root' user
USER root

# Install libgl1-mesa-glx to disable libGL.so.1 load warning
RUN apt-get update && \
    apt-get install -yq --no-install-recommends pkg-config libgl1-mesa-glx gnupg software-properties-common && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add - && \
    apt-add-repository "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-6.0 main" && \
    apt-get update && \
    apt-get install -yq --no-install-recommends clang-6.0 gcc && \
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/*

# Install dlib
RUN apt-get install -y --fix-missing \
    build-essential \
    cmake \
    gfortran \
    git \
    wget \
    curl \
    graphicsmagick \
    libgraphicsmagick1-dev \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    liblapack-dev \
    libswscale-dev \
    pkg-config \
    python3-dev \
    software-properties-common \
    zip \
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

RUN pip install --upgrade pip setuptools && \
    pip install --upgrade numpy dlib matplotlib && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN cd ~ && \
    mkdir -p dlib && \
    git clone -b 'v19.18' --single-branch https://github.com/davisking/dlib.git dlib/ && \
    cd  dlib/ && \
    mkdir build && \
    cd build && \
    cmake -DWITH_CUDA=OFF -DBUILD_SHARED_LIBS=1 .. && \
    make -j 4 && \
    make install && \
    ldconfig

# Activate the 'joyvan' user
USER $NB_UID

# Install xeus-calling
RUN conda install --yes \
    -c QuantStack \
    -c conda-forge \
    xeus-cling opencv && \
    conda clean -tipy && \
    fix-permissions $CONDA_DIR

# Disable authentication
RUN mkdir -p .jupyter
RUN echo "" >> ~/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py
