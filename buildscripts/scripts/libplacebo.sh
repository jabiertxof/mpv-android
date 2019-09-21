#!/bin/bash -e

. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

# Android provides Vulkan, but no pkg-config file
mkdir -p "$prefix_dir"/lib/pkgconfig
cat >"$prefix_dir"/lib/pkgconfig/vulkan.pc <<"END"
Name: Vulkan
Description:
Version: 1.1
Libs: -lvulkan
Cflags:
END

ndk_vulkan="$(dirname "$(which ndk-build)")/sources/third_party/vulkan"

unset CC CXX
meson $build \
	--buildtype release --cross-file "$prefix_dir"/crossfile.txt \
	--default-library static -Dvulkan-registry="$ndk_vulkan/src/registry/vk.xml"

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install
