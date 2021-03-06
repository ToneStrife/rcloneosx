## RcloneOSX

![](icon/rcloneosx.png)

The project is a adapting [RsyncOSX](https://github.com/rsyncOSX/RsyncOSX) utilizing [rclone](https://rclone.org/) for synchronizing and backup of catalogs and files to a number of cloud services. RcloneOSX utilizes `rclone copy`, `sync`, `move` and `check` commands.

This repository is the source code for the macOS app RcloneOSX. RcloneOSX is compiled with support for macOS El Capitan version 10.11 - macOS Mojave version 10.14. The application is implemented in Swift 5 by using Xcode 10.

RcloneOSX require the `rclone` command line utility to be installed. If installed in other directory than `/usr/local/bin`, please change directory by user Configuration in RcloneOSX. RcloneOSX checks if there is a rclone installed in the provided directory.

Rclone is *rsync for cloud storage*. Even if `rclone` and `rsync` are somewhat equal they are also in many ways different. RcloneOSX is built upon the ideas from RsyncOSX. But it is not possible to clone all functions in RsyncOSX to RcloneOSX. I spend most of my time developing RsyncOSX. From time to time some functions are ported to RcloneOSX from RsyncOSX. I am not an advanced user of `rclone`. My main use of RcloneOSX is  synchronizing my GitHub catalog to Dropbox and Google.

### Fighting bugs

Fighting bugs are difficult. I am not able to test RcloneOSX for all possible user interactions and use. From time to time I discover new bugs. But I also need support from other users discovering bugs or not expected results. If you discover a bug **please** use the [issues](https://github.com/rsyncOSX/rcloneosx/issues) and report it.

### Main view

The main view of RcloneOSX.
![](images/main1.png)
Estimation of task for sync completed.
![](images/main2.png)
Sync of task in action.
![](images/main3.png)

### Signing and notarizing

The app is signed with my Apple ID developer certificate and [notarized](https://support.apple.com/en-us/HT202491) by Apple. See [signing and notarizing](https://rsyncosx.github.io/Notarized) for info.

### Application icon

The application icon is created by [Zsolt Sándor](https://github.com/graphis). All rights reserved to Zsolt Sándor.

### Changelog

The [Changelog](https://rsyncosx.github.io/RcloneChangelog).

### Compile

To compile the code, install Xcode and open the RcloneOSX project file. Before compiling, open in Xcode the `RcloneOSX/General` preference page (after opening the RcloneOSX project file) and replace your own credentials in `Signing`, or disable Signing.

There are two ways to compile, either utilize `make` or compile by Xcode. `make release` will compile the `rcloneosx.app` and `make dmg` will make a dmg file to be released.  The build of dmg files are by utilizing [andreyvit](https://github.com/andreyvit/create-dmg) script for creating dmg and [syncthing-macos](https://github.com/syncthing/syncthing-macos) setup.
