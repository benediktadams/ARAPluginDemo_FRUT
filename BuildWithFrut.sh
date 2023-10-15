#!/bin/bash

BASE_DIR=$(pwd $(dirname "$0"))
cd "$BASE_DIR"

FRUT_DIR="$BASE_DIR/Submodules/FRUT"
FRUT_BUILD_DIR="$FRUT_DIR/build"
cd "$FRUT_DIR"

if [ ! -d "$FRUT_BUILD_DIR" ]; then
    mkdir "$FRUT_BUILD_DIR"
fi

cd "$FRUT_BUILD_DIR"
echo "Building FRUT from $FRUT_BUILD_DIR"
cmake .. -DCMAKE_INSTALL_PREFIX="../prefix" -DJUCE_ROOT="../../JUCE" || exit 1
cmake -E env CXXFLAGS="-Wno-unused-parameter -Wno-poison-system-directories" cmake .. || exit 2
cmake --build . --target install --parallel 8 || exit 3

cd "$BASE_DIR"

JUCERPROJ="$BASE_DIR/ARAPluginDemo.jucer"

"$FRUT_DIR/prefix/FRUT/bin/Jucer2CMake" reprojucer "$JUCERPROJ" "$FRUT_DIR/cmake/Reprojucer.cmake" || exit 4

CMAKEFILE="$BASE_DIR/CMakeLists.txt"

BUILD_PATH="$BASE_DIR/Builds/cmakebuilds"

if [ ! -d "$BUILD_PATH" ]; then
    mkdir -p "$BUILD_PATH"
fi

cd "$BUILD_PATH"

echo "Building ARAPluginDemo"
cmake ../.. -G "Xcode" || exit 5
cmake --build . --config "Debug" -j8 || exit 6

cd "$BASE_DIR"

exit 0