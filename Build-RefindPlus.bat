@echo off
REM Build-RefindPlus.bat - Build RefindPlus with CLANG38 toolchain
REM
REM Place this script in the RefindPlus root directory and run:
REM   Build-RefindPlus.bat         - Build RELEASE (default)
REM   Build-RefindPlus.bat REL     - Build RELEASE
REM   Build-RefindPlus.bat DBG     - Build DEBUG
REM   Build-RefindPlus.bat ALL     - Build all (REL, DBG, NOOPT)

setlocal EnableExtensions EnableDelayedExpansion

REM Determine directories
set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%"
set "EDK2_DIR=%ROOT_DIR%"
set "WORKSPACE=%EDK2_DIR%"

set "BUILD_TYPE=%~1"
if not defined BUILD_TYPE set "BUILD_TYPE=REL"

set "RUN_REL=0"
set "RUN_DBG=0"
set "RUN_NPT=0"

if /I "%BUILD_TYPE%"=="REL" (
  set "RUN_REL=1"
) else if /I "%BUILD_TYPE%"=="DBG" (
  set "RUN_DBG=1"
) else if /I "%BUILD_TYPE%"=="NPT" (
  set "RUN_NPT=1"
) else if /I "%BUILD_TYPE%"=="ALL" (
  set "RUN_REL=1"
  set "RUN_DBG=1"
  set "RUN_NPT=1"
) else (
  set "RUN_REL=1"
)

REM Ensure build directories exist
if not exist "%EDK2_DIR%\Build" mkdir "%EDK2_DIR%\Build"
if not exist "%EDK2_DIR%\000-BOOTx64-Files" mkdir "%EDK2_DIR%\000-BOOTx64-Files"

REM Run build
pushd "%EDK2_DIR%"

REM Set up environment using edksetup.bat to properly configure everything
call edksetup.bat

REM Set additional paths
set PATH=%EDK_TOOLS_BIN%;C:\Python27;C:\Python27\Scripts;C:\LLVM\bin;%PATH%
set PYTHON_HOME=C:\Python27
set PYTHONPATH=%EDK_TOOLS_PATH%\Source\Python

if "%RUN_REL%"=="1" (
  echo.
  echo ===== Building RELEASE with CLANG38 =====
  if exist "Build\RefindPlus\RELEASE_CLANG38" rmdir /s /q "Build\RefindPlus\RELEASE_CLANG38"
  call :do_build RELEASE
)

if "%RUN_DBG%"=="1" (
  echo.
  echo ===== Building DEBUG with CLANG38 =====
  if exist "Build\RefindPlus\DEBUG_CLANG38" rmdir /s /q "Build\RefindPlus\DEBUG_CLANG38"
  call :do_build DEBUG
)

if "%RUN_NPT%"=="1" (
  echo.
  echo ===== Building NOOPT with CLANG38 =====
  if exist "Build\RefindPlus\NOOPT_CLANG38" rmdir /s /q "Build\RefindPlus\NOOPT_CLANG38"
  call :do_build NOOPT
)

popd

echo.
echo Build complete!
echo   BOOTx64 files: %EDK2_DIR%\000-BOOTx64-Files
if "%RUN_REL%"=="1" echo   REL: %EDK2_DIR%\Build\RefindPlus\RELEASE_CLANG38\X64\RefindPlus.efi
if "%RUN_DBG%"=="1" echo   DBG: %EDK2_DIR%\Build\RefindPlus\DEBUG_CLANG38\X64\RefindPlus.efi
if "%RUN_NPT%"=="1" echo   NPT: %EDK2_DIR%\Build\RefindPlus\NOOPT_CLANG38\X64\RefindPlus.efi

endlocal
exit /b 0

:do_build
set "TARGET=%~1"

C:\Python27\python.exe BaseTools\Source\Python\build\build.py -a X64 -b %TARGET% -t CLANG38 -p RefindPlusPkg\RefindPlusPkg.dsc
if errorlevel 1 (
  echo Build failed!
  exit /b 1
)

REM Fix for GenFw section classification bug: strip WRITE from .text section
REM Without this, old GenFw misclassifies .text as DATA due to -fpie adding SHF_WRITE
set "ELF_DLL=Build\RefindPlus\%TARGET%_CLANG38\X64\RefindPlusPkg\RefindPlus\DEBUG\RefindPlus.dll"
set "FIXED_DLL=Build\RefindPlus\%TARGET%_CLANG38\X64\RefindPlusPkg\RefindPlus\DEBUG\RefindPlus_fixed.dll"
set "OUTPUT_EFI=Build\RefindPlus\%TARGET%_CLANG38\X64\RefindPlus.efi"

if exist "%ELF_DLL%" (
  echo.
  echo Fixing ELF .text section flags for GenFw...
  "C:\LLVM\bin\llvm-objcopy.exe" --set-section-flags .text=alloc,code,readonly "%ELF_DLL%" "%FIXED_DLL%"
  "GenFw" -z -e UEFI_APPLICATION -o "%OUTPUT_EFI%" "%FIXED_DLL%"
  copy /y "%OUTPUT_EFI%" "000-BOOTx64-Files\" >nul
)
echo Build complete!! press any key to exit
pause
exit /b 0