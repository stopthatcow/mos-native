# mos-native

Installer script to download, build and install all dependencies needed for [mos tool](https://github.com/mongoose-os/mos) to build Mongoose OS apps for ESP32 without docker.

## install
```bash
$ git clone https://github.com/v-kiniv/mos-native.git
$ cd mos-native
$ ./install.sh
```
The installer downloads the esp-idf to the `CWD`and installs the compiler to `~/.espressif/`.

It generates a build tool script called `mos_build_local.sh` that you can use to build locally.

To build, use the generated shell script `mos_build_local.sh`
```bash
mos_build_local.sh --platform esp32
```

You will likely want to make a symlink to this file somewhere on your path or add an alias in your .bashrc/.zshrc file.

## uninstall
```bash
$ ./uninstall.sh
```
