FROM ubuntu:bionic
LABEL Description="Collection of C++ development tools"
LABEL Maintainer="Jonathan Vander Mey <jonathan@vandermey.ca>"

# Prerequisitie packages
RUN apt-get update                                   \
    && apt-get install -y cmake                      \
                          git                        \
                          libpcre++-dev              \
                          python3-dev                \
                          python3-pip                \
                          software-properties-common \
                          wget                       \
    && python3 -m pip install --upgrade pip          \
    && python3 -m pip install --upgrade cmake_format \
    && python3 -m pip install --upgrade pyyaml       \
    && ln -s /usr/bin/python3 /usr/bin/python

# Setup for Clang
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -                          \
    && add-apt-repository -y "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-7 main"     \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test                                        \
    && apt-get update

# Clang and Clang-Tools
RUN apt-get install -y clang-7        \
                       clang++-7      \
                       clang-format-7 \
                       clang-tidy-7   \
                       llvm-7-dev     \
                       libclang-7-dev

# CppCheck
RUN git clone -b 1.86 --depth 1 https://github.com/danmar/cppcheck.git           \
    && cd cppcheck                                                               \
    && make SRCDIR=build CFGDIR=/usr/share/cppcheck/cfg HAVE_RULES=yes           \
            CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function" \
    && make CFGDIR=/usr/share/cppcheck/cfg install                               \
    && cd ..                                                                     \
    && rm -rf cppcheck

# IWYU
RUN git clone -b clang_7.0 --depth 1 https://github.com/include-what-you-use/include-what-you-use.git \
    && mkdir build                                                                           \
    && cd build                                                                              \
    && cmake -G "Unix Makefiles" -D CMAKE_INSTALL_PREFIX=/usr -DCMAKE_PREFIX_PATH=/usr/lib/llvm-7 ../include-what-you-use \
    && make                                                                                  \
    && make install                                                                          \
    && cd ../..                                                                              \
    && rm -rf build include-what-you-use
