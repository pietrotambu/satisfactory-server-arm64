FROM ubuntu:24.04 AS builder
SHELL ["/bin/bash", "-c"]

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl python3 sudo expect-dev software-properties-common \
    squashfs-tools squashfuse git python3-setuptools pkgconf clang \
    binfmt-support systemd cmake ninja-build \
    libncurses6 libtinfo6 libncurses-dev \
    libsdl2-dev libepoxy-dev libssl-dev llvm lld \
    qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
    libqt5core5a libqt5gui5 libqt5widgets5 qtdeclarative5-dev \
    qml-module-qtquick2 qml-module-qtquick-controls2 \
    qml-module-qtquick-window2 nasm \
    && rm -rf /var/lib/apt/lists/*

# Add FEX PPA and clone source
RUN add-apt-repository -y ppa:fex-emu/fex

RUN git clone --recurse-submodules https://github.com/FEX-Emu/FEX.git /FEX

WORKDIR /FEX
# Reverting to an older commit due to FEXEmu updates breaking the build process
RUN git checkout 0072b289bbf9f59b89c117158118375397532aad && \
    git submodule update --init --recursive && \
    sed -i 's@USE_LEGACY_BINFMTMISC "Uses legacy method of setting up binfmt_misc" FALSE@USE_LEGACY_BINFMTMISC "Uses legacy method of setting up binfmt_misc" TRUE@' ./CMakeLists.txt

WORKDIR /FEX/Build
RUN CC=clang CXX=clang++ cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_LINKER=lld \
    -DENABLE_LTO=True \
    -DBUILD_TESTS=False \
    -DENABLE_ASSERTIONS=False \
    -G Ninja .. && \
    ninja && ninja install && ninja binfmt_misc

# Install FEX root FS
RUN userdel -r ubuntu && useradd -m -u 1000 steam && \
    sudo -u steam bash -c "unbuffer FEXRootFSFetcher -y -x"


FROM ubuntu:24.04
SHELL ["/bin/bash", "-c"]

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates squashfuse binfmt-support \
    libncurses6 libtinfo6 \
    libsdl2-2.0-0 libepoxy0 libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Copy FEX binaries from builder
COPY --from=builder /usr/bin/FEX* /usr/bin/

RUN userdel -r ubuntu && useradd -m -u 1000 steam && \
    mkdir /home/steam/Steam && chown steam:steam /home/steam/Steam

COPY --from=builder --chown=steam:steam /home/steam/.fex-emu /home/steam/.fex-emu

USER steam
WORKDIR /home/steam

ENTRYPOINT ["/bin/bash"]
