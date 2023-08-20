cmake_minimum_required(VERSION 3.10)
project(mkvtools)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

add_definitions(
    -DMTX_LOCALE_DIR="."
    -DMTX_PKG_DATA_DIR="."
    -DMTX_DOC_DIR="."
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DQT_DBUS_LIB -DQT_CORE_LIB -Wnon-virtual-dtor -Wextra -Wno-missing-field-initializers -Wunused -Wpedantic -Wno-maybe-uninitialized -Wlogical-op -Wno-extra-semi -Wmisleading-indentation -Wduplicated-cond -Wshadow-compatible-local -Wduplicated-branches -Wno-deprecated-copy -Wno-stringop-overflow")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_FILE_OFFSET_BITS=64 -DQT_NO_KEYWORDS")

# Find required packages
find_package(Qt5 COMPONENTS Core DBus REQUIRED)
find_package(Boost REQUIRED COMPONENTS filesystem system)
find_package(Ogg REQUIRED)
find_package(Vorbis REQUIRED)
find_package(FLAC REQUIRED)
find_package(pugixml REQUIRED)
find_package(fmt REQUIRED)
find_package(Iconv REQUIRED)
find_package(ZLIB REQUIRED)
find_package(GMP REQUIRED)
find_package(EBML REQUIRED)
find_package(Matroska REQUIRED)

include_directories(
    src
    lib
    lib/nlohmann-json/include
    lib/avilib-0.6.10
    lib/utf8-cpp/source
    ${Qt5Core_INCLUDE_DIRS}
    ${Qt5DBus_INCLUDE_DIRS}
)

# Generate version header
set(version "78.0")
set(mkvtoolnix_version_file "src/common/mkvtoolnix_version.h")
file(WRITE "${mkvtoolnix_version_file}" "#define MKVTOOLNIX_VERSION \"${version}\"")
message(STATUS "Generated version header: ${mkvtoolnix_version_file}")

# Build common library
file(GLOB_RECURSE common_sources src/common/*.cpp)
list(FILTER common_sources EXCLUDE REGEX "windows.cpp|macos.cpp")
add_library(mtxcommon STATIC ${common_sources})

# Build extract library
file(GLOB_RECURSE extract_sources src/extract/*.cpp)
list(FILTER extract_sources EXCLUDE REGEX "mkvextract.cpp")
add_library(mtxextract STATIC ${extract_sources})

# Build avilib library
add_library(avi STATIC
    lib/avilib-0.6.10/avilib.c
    lib/avilib-0.6.10/avimisc.c
    lib/avilib-0.6.10/xio.cpp
)

# Build librmff library
add_library(rmff STATIC
    lib/librmff/mb_file_io.c
    lib/librmff/rmff.c
)

# Build mkvinfo executable
add_executable(mkvinfo
    src/info/info_cli_parser.cpp
    src/info/mkvinfo.cpp
)
target_link_libraries(mkvinfo
    mtxcommon
    Boost::filesystem
    Boost::system
    FLAC::FLAC
    pugixml::pugixml
    Iconv::Iconv
    fmt::fmt
    Qt5::Core
    pthread
    ZLIB::ZLIB
    Qt5::DBus
    GMP::GMP
    Matroska::matroska
    EBML::ebml
)

# Build mkvextract executable
add_executable(mkvextract
    src/extract/mkvextract.cpp
)
target_link_libraries(mkvextract
    mtxextract
    mtxcommon
    Boost::filesystem
    Boost::system
    FLAC::FLAC
    pugixml::pugixml
    Iconv::Iconv
    fmt::fmt
    Qt5::Core
    pthread
    ZLIB::ZLIB
    Qt5::DBus
    GMP::GMP
    Matroska::matroska
    EBML::ebml
    avi
    rmff
    Vorbis::vorbis
    Ogg::ogg
)