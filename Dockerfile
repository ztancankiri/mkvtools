FROM alpine AS base

WORKDIR /repos

RUN apk update && apk add gcc g++ linux-headers make cmake ruby-rake python3-dev autoconf automake libtool lld pkgconfig curl wget git docbook-xsl \
    && cd /repos && git clone --depth 1 https://github.com/xiph/ogg.git && cd ogg \
    && mkdir build && cd build \
    && cmake .. -DBUILD_SHARED_LIBS=OFF \
    && make -j$(nproc) && make install \
    && cd /repos && git clone --depth 1 https://github.com/xiph/vorbis.git && cd vorbis \
    && mkdir build && cd build \
    && cmake .. -DBUILD_SHARED_LIBS=OFF \
    && make -j$(nproc) && make install \
    && cd /repos && git clone --depth 1 https://github.com/xiph/flac.git && cd flac \
    && mkdir build && cd build \
    && cmake .. -DBUILD_SHARED_LIBS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF -DCBUILD_DOCS=OFF -DCBUILD_DOCS=OFF -DINSTALL_MANPAGES=OFF \
    && make -j$(nproc) && make install \
    && cd /repos && git clone --depth 1 https://github.com/madler/zlib.git && cd zlib \
    && ./configure --static \
    && make -j$(nproc) && make install \
    && cd /repos && git clone --depth 1 https://github.com/Matroska-Org/libebml.git && cd libebml \
    && mkdir build && cd build \
    && cmake .. -DBUILD_SHARED_LIBS=OFF -DENABLE_WIN32_IO=OFF \
    && make -j$(nproc) && make install \
    && cd /repos && git clone --depth 1 https://github.com/Matroska-Org/libmatroska.git && cd libmatroska \
    && mkdir build && cd build \
    && cmake .. -DBUILD_SHARED_LIBS=OFF -DBUILD_EXAMPLES=OFF \
    && make -j$(nproc) && make install \
    && cd /repos && git clone --depth 1 https://github.com/zeux/pugixml.git && cd pugixml \
    && mkdir build && cd build \
    && cmake .. -DBUILD_SHARED_LIBS=OFF \
    && make -j$(nproc) && make install \
    && cd /repos && git clone --depth 1 https://github.com/fmtlib/fmt.git && cd fmt \
    && mkdir build && cd build \
    && cmake .. -DBUILD_SHARED_LIBS=OFF \
    && make -j$(nproc) && make install \
    && cd /repos && wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz && tar -xvf libiconv-1.17.tar.gz && rm -rf libiconv-1.17.tar.gz && cd libiconv-1.17 \
    && ./configure --enable-static=yes --enable-shared=no --disable-nls \
    && make -j$(nproc) && make install \
    && cd /repos && wget https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz && tar -xvf gmp-6.3.0.tar.xz && rm -rf gmp-6.3.0.tar.xz && cd gmp-6.3.0 \
    && ./configure --enable-shared=no --enable-static=yes \
    && make -j$(nproc) && make install \
    && cd /repos  && wget https://download.qt.io/archive/qt/5.15/5.15.10/single/qt-everywhere-opensource-src-5.15.10.tar.xz && tar -xvf qt-everywhere-opensource-src-5.15.10.tar.xz && rm -rf qt-everywhere-opensource-src-5.15.10.tar.xz && cd qt-everywhere-src-5.15.10 \
    && ./configure --prefix=/usr/local -static -release -opensource -confirm-license -no-icu -no-pch -no-opengl -skip qtwebengine -nomake tests -nomake examples -DBUILD_SHARED_LIBS=OFF \
    && make -j$(nproc) && make install \
    && cd /repos && wget https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.tar.gz && tar -xvf boost_1_82_0.tar.gz && rm -rf boost_1_82_0.tar.gz && cd boost_1_82_0 \
    && ./bootstrap.sh --prefix=/usr/local --with-libraries=all \
    && ./b2 -j$(nproc) link=static install

WORKDIR /app
RUN rm -rf /repos

COPY CMakeLists.txt .
COPY cmake cmake
COPY src src
COPY lib lib

RUN mkdir build && cd build && cmake .. && make -j$(nproc)

FROM alpine
WORKDIR /
COPY --from=base /app/build/mkvinfo /
COPY --from=base /app/build/mkvextract /