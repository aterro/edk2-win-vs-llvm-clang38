# RefindPlus EDK2 (Abz-Mod Edition) - edk2-win-vs-llvm-clang38
Modified EDK2 build environment for RefindPlus with Abz-Mods enhancements.
## Build Requirements
- Windows 11
- Visual Studio 2022+ (with C++ and Windows SDK)
- LLVM-Clang 18.x toolchain (download llvm for windows install to c:\llvm)
- Python 2.7 (download it and install to c:\python27)
## Features
- Mouse support on legacy BIOS/UEFI 1.x firmware and older 2.x firmware
- Enhanced GUI with improved themes and visual styling
- Additional boot options and configuration enhancements
- Build on Windows 11 with LLVM-Clang 38 toolchain
## Building
Download the Build-RefindPlus.bat from releases
P.S. Place it along with "edk2" in the same folder

Run `Build-RefindPlus.bat` from the project root:
```batch
Build-RefindPlus.bat         # RELEASE (default)
Build-RefindPlus.bat REL     # RELEASE
Build-RefindPlus.bat DBG    # DEBUG
Build-RefindPlus.bat ALL    # REL + DBG + NOOPT
```
Output files:
- `edk2/000-BOOTx64-Files/RefindPlus.efi`
- `edk2/Build/RefindPlus/RELEASE_CLANG38/X64/RefindPlus.efi`
## Toolchain Notes
Uses LLVM-Clang 38 with the following customizations:
- `-target x86_64-pc-linux-gnu` for cross-compilation to UEFI
- `-fno-pie -mno-red-zone` for EFI compatibility
- `-D__MAKEWITH_TIANO` for EDK II build
- `-D__BUILDING_ON_WINDOWS__` to detect Windows build host
## Credits
Based on RefindPlus by Dayo Akanji & Contributors
Original by Roderick W. Smith (Portions)