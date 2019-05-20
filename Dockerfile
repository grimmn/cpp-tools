FROM ubuntu:bionic
LABEL Description="Collection of C++ development tools"
LABEL Maintainer="Jonathan Vander Mey <jonathan@vandermey.ca>"

RUN apt-get update                          \
    && apt-get install -y git               \
                          libpcre++-dev     \
                          python3-dev       \
                          python3-pip       \
                          wget              \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install --upgrade pyyaml \
    && ln -s /usr/bin/python3 /usr/bin/python

ARG llvm_file=clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04
RUN wget --no-verbose http://releases.llvm.org/8.0.0/${llvm_file}.tar.xz \
    && tar xf ${llvm_file}.tar.xz                                        \
    && cp -pr ${llvm_file}/* /usr/local                                  \
    && rm ${llvm_file}.tar.xz                                            \
    && rm -rf ${llvm_file}                                               \
    && ln -s /usr/local/share/clang/run-clang-tidy.py                    \
             /usr/local/bin/run-clang-tidy

RUN git clone -b 1.86 --depth 1 https://github.com/danmar/cppcheck.git           \
    && cd cppcheck                                                               \
    && make SRCDIR=build CFGDIR=/usr/share/cppcheck/cfg HAVE_RULES=yes           \
            CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function" \
    && make CFGDIR=/usr/share/cppcheck/cfg install                               \
    && cd ..                                                                     \
    && rm -rf cppcheck

