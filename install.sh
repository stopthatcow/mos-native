INSTALL_PATH=$PWD
MOS_VERSION=2.20.0
DOCKER_TAG=4.2-r8
TOOLCHAIN_VERSION=esp-2020r3-8.4.0

echo $'\e[36mInstalling ESP-IDF...\e[0m'
rm -rf $INSTALL_PATH/esp-idf
git clone --depth=1 --recursive --branch $DOCKER_TAG https://github.com/mongoose-os/esp-idf $INSTALL_PATH/esp-idf
sh -c "cd $INSTALL_PATH/esp-idf; ./patch_submodules.sh"
sh $INSTALL_PATH/esp-idf/install.sh


echo $'\e[36mFinding IDF python virtual env...\e[0m'
IDF_PYTHON_ENV_NAME="$(ls "$HOME/.espressif/python_env")"
IDF_PYTHON_ENV_PATH="$HOME/.espressif/python_env/$IDF_PYTHON_ENV_NAME"
IDF_PYTHON_ENV_ACTIVATE="$IDF_PYTHON_ENV_PATH/bin/activate"
if [ ! -f "$IDF_PYTHON_ENV_ACTIVATE" ]; then
  echo "Didn't find expected virtual env at $IDF_PYTHON_ENV_ACTIVATE";
  exit 1
fi
echo "Setting IDF_PYTHON_ENV_PATH to $IDF_PYTHON_ENV_PATH"

echo $'\e[36mInstalling pyyaml...\e[0m'
. "$IDF_PYTHON_ENV_ACTIVATE"
pip install pyyaml
deactivate

echo $'\e[36mInstalling Mongoose-OS...\e[0m'
rm -rf $INSTALL_PATH/mongoose-os
git clone --depth=1 --branch $MOS_VERSION https://github.com/cesanta/mongoose-os $INSTALL_PATH/mongoose-os

echo $'\e[36mInstalling LFS tools...\e[0m'
rm -rf $INSTALL_PATH/vfs-fs-lfs
git clone --depth=1 https://github.com/mongoose-os-libs/vfs-fs-lfs
make -C $INSTALL_PATH/vfs-fs-lfs/tools mklfs FROZEN_PATH=$INSTALL_PATH/mongoose-os/src/frozen
cp $INSTALL_PATH/vfs-fs-lfs/tools/mklfs /usr/local/bin
rm -rf $INSTALL_PATH/vfs-fs-lfs

echo $'\e[36mIntalling SPIFFS tools...\e[0m'
rm -rf $INSTALL_PATH/vfs-fs-spiffs
git clone --depth=1 https://github.com/mongoose-os-libs/vfs-fs-spiffs
make -C $INSTALL_PATH/vfs-fs-spiffs/tools mkspiffs mkspiffs8 FROZEN_PATH=$INSTALL_PATH/mongoose-os/src/frozen SPIFFS_CONFIG_PATH=$INSTALL_PATH/vfs-fs-spiffs/include/esp32xx
cp $INSTALL_PATH/vfs-fs-spiffs/tools/mkspiffs $INSTALL_PATH/vfs-fs-spiffs/tools/mkspiffs8 /usr/local/bin
rm -rf $INSTALL_PATH/vfs-fs-spiffs
rm -rf $INSTALL_PATH/mongoose-os

echo $'\e[92mDone.\e[0m'

# Create invocation script
echo "\
#!/bin/bash

export PATH=\"\$HOME/.espressif/tools/xtensa-esp32-elf/$TOOLCHAIN_VERSION/xtensa-esp32-elf/bin:\$PATH\"
export IDF_PATH=\"$INSTALL_PATH/esp-idf\"
export IDF_PYTHON_ENV_PATH=\"$IDF_PYTHON_ENV_PATH\"
export MGOS_TARGET_GDB=\"\$HOME/.espressif/tools/xtensa-esp32-elf/$TOOLCHAIN_VERSION/xtensa-esp32-elf/bin/xtensa-esp32-elf-gdb\"
export MGOS_SDK_REVISION=$DOCKER_TAG
export TOOLCHAIN_VERSION=$TOOLCHAIN_VERSION
export MGOS_SDK_BUILD_IMAGE=docker.io/mgos/esp32-build:$DOCKER_TAG
export CPPFLAGS=\"\$CPPFLAGS -Wno-error\"\

# Enable ESP-IDF python env.
. \"$IDF_PYTHON_ENV_ACTIVATE\"

# Build with mos, forwarding args.
/usr/local/bin/mos \${@:1} | grep -v \"<command-line>:\"; ( exit \${PIPESTATUS[0]} )
" > mos_naitive
chmod 755 mos_naitive

# Create uninstall script
echo "\
echo $'\e[36mRemoving binaries from /usr/local/bin...\e[0m'
rm /usr/local/bin/mklfs
rm /usr/local/bin/mkspiffs
rm /usr/local/bin/mkspiffs8
echo $'\e[92mDone.\e[0m'\
" > uninstall.sh
chmod 755 uninstall.sh
