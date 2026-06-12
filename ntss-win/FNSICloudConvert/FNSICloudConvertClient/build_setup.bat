@echo off
rem build_setup.bat — WiX 4 / HeatWave SDK スタイルでセットアッププロジェクトのみビルド

set PROJ=D:\ntss\ntss-win_copy_V2.0A\FNSICloudConvert\FNSICloudConvertClient\Setup\FNSICloudConvertClient.Setup.wixproj
set APPBINDIR=D:\ntss\ntss-win_copy_V2.0A\FNSICloudConvert\FNSICloudConvertClient\FNSICloudConvertClient\bin\Release
set MSBUILD=

if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
  for /f "usebackq delims=" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -version "[16.0,17.0)" -products * -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe"`) do (
    if not defined MSBUILD set MSBUILD=%%i
  )
)

if not defined MSBUILD if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" set MSBUILD=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe
if not defined MSBUILD if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" set MSBUILD=C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe
if not defined MSBUILD if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe" set MSBUILD=C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe
if not defined MSBUILD if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe" set MSBUILD=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe

if not defined MSBUILD (
  echo MSBuild.exe for Visual Studio 2019 was not found.
  exit /b 1
)

"%MSBUILD%" "%PROJ%" /restore /t:Build /p:Configuration=Release /p:Platform=x86 /p:AppBinDir="%APPBINDIR%" /v:minimal
