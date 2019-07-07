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
    && python3 -m pip install --upgrade conan        \
    && ln -s /usr/bin/python3 /usr/bin/python

# Setup for Clang
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -                          \
    && add-apt-repository -y "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-8 main"     \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test                                        \
    && apt-get update

# Clang and Clang-Tools
RUN apt-get install -y clang-8                                 \
                       clang++-8                               \
                       clang-format-8                          \
                       clang-tidy-8                            \
                       llvm-8-dev                              \
                       libclang-8-dev                          \
    && ln -s /usr/bin/clang-8 /usr/bin/clang                   \
    && ln -s /usr/bin/clang++-8 /usr/bin/clang++               \
    && ln -s /usr/bin/clang-format-8 /usr/bin/clang-format     \
    && ln -s /usr/bin/clang-tidy-8 /usr/bin/clang-tidy         \
    && ln -s /usr/bin/run-clang-tidy-8 /usr/bin/run-clang-tidy


# CppCheck
RUN git clone -b 1.88 --depth 1 https://github.com/danmar/cppcheck.git           \
    && cd cppcheck                                                               \
    && make MATCHCOMPILER=yes CFGDIR=/usr/share/cppcheck/cfg HAVE_RULES=yes           \
            CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function" \
    && make CFGDIR=/usr/share/cppcheck/cfg install                               \
    && cd ..                                                                     \
    && rm -rf cppcheck

# IWYU
RUN git clone -b clang_8.0 --depth 1 https://github.com/include-what-you-use/include-what-you-use.git \
    && mkdir build                                                                           \
    && cd build                                                                              \
    && cmake -G "Unix Makefiles" -D CMAKE_INSTALL_PREFIX=/usr -DCMAKE_PREFIX_PATH=/usr/lib/llvm-8 ../include-what-you-use \
    && make                                                                                  \
    && make install                                                                          \
    && cd ../..                                                                              \
    && rm -rf build include-what-you-use
