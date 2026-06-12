# build_setup.ps1 — WiX 4 / HeatWave SDK スタイルでセットアッププロジェクトのみビルド

$ErrorActionPreference = "Stop"

$proj      = "D:\ntss\ntss-win_copy_V2.0A\FNSICloudConvert\FNSICloudConvertClient\Setup\FNSICloudConvertClient.Setup.wixproj"
$appBinDir = "D:\ntss\ntss-win_copy_V2.0A\FNSICloudConvert\FNSICloudConvertClient\FNSICloudConvertClient\bin\Release"

function Get-MSBuildPath {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        $path = & $vswhere -version "[16.0,17.0)" -products * -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe" | Select-Object -First 1
        if ($path) { return $path }
    }

    $fallbacks = @(
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    )

    foreach ($candidate in $fallbacks) {
        if (Test-Path $candidate) { return $candidate }
    }

    throw "MSBuild.exe for Visual Studio 2019 was not found."
}

$msbuild = Get-MSBuildPath

Write-Host "=== Setup Release ビルド ===" -ForegroundColor Cyan
& $msbuild $proj /restore /t:Build /p:Configuration=Release /p:Platform=x86 "/p:AppBinDir=$appBinDir" /v:minimal
exit $LASTEXITCODE
