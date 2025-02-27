# mos-native

Installer script to download, build and install all dependencies needed for [mos tool](https://github.com/mongoose-os/mos) to build Mongoose OS apps for ESP32 without docker. Docker on Mac is painfully slow and builds can take many minutes. Much of this slowness seems due to using gRPC FUSE and with the advent of VirtioFS docker performance is better. However compared to Docker Desktop v4.16.1 using VirtioFS I see compile times take about half as long using the naitive approach.

## install
```bash
git clone https://github.com/stopthatcow/mos-native.git
cd mos-native
./install.sh
```
The installer downloads the esp-idf to the current directory and installs the compiler to `~/.espressif/`.
Because the IDF uses its own virtual environment for python that we don't want to keep activated all the time, we generate a helper script to activate this environment before invoking `mos`.
The helper script is generated by the installer and is called `mos_naitive`.

To build your firmware, use the generated shell script `mos_naitive` just as you would `mos`.
```bash
mos_naitive --platform esp32 build --local
```

You will likely want to move/symlink this file somewhere on your path or add an alias in your .bashrc/.zshrc file.
e.g.
```bash
alias mos_naitive=</PATH/TO>/mos-native/mos_naitive
```

## uninstall
```bash
$ ./uninstall.sh
```
