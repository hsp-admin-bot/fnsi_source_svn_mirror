<#
  build_package.ps1 - FNSICloudConvertClient MSI build script (WiX 4)

  Usage:
    .\build_package.ps1
    .\build_package.ps1 -SkipBuild
    .\build_package.ps1 -ForceHarvest
    .\build_package.ps1 -SuppressValidation

  Notes:
    - WiX 4 project build is handled by VS2019 MSBuild + local WiX 4.0.6 cache.
    - HarvestedFiles.wxs is regenerated from the Release output when the file list changes.

  Output: Setup\bin\Release\FNSICloudConvertClient.msi
#>
param(
    [switch]$SkipBuild,
    [switch]$ForceHarvest,
    [switch]$SuppressValidation
)

$ErrorActionPreference = "Stop"

$baseDir    = "D:\ntss\ntss-win_copy_V2.0A\FNSICloudConvert\FNSICloudConvertClient"
$appProj    = "$baseDir\FNSICloudConvertClient\FNSICloudConvertClient.csproj"
$setupProj  = "$baseDir\Setup\FNSICloudConvertClient.Setup.wixproj"
$appBinDir  = "$baseDir\FNSICloudConvertClient\bin\Release"
$harvestOut = "$baseDir\Setup\Generated\HarvestedFiles.wxs"
$msiOut     = "$baseDir\Setup\bin\Release\FNSICloudConvertClient.msi"

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

$excludePatterns = @(
    '^LOG\\',
    '^DbMigrationTool\.exe$',
    '^DbMigrationTool\.exe\.config$',
    '^DbMigrationTool\.pdb$',
    '^user_settings\.json$',
    '\.log$',
    '\.pdb$',
    '\.xml$'
)

function Test-Excluded($relativePath) {
    foreach ($pat in $excludePatterns) {
        if ($relativePath -match $pat) { return $true }
    }
    return $false
}

if ($SkipBuild) {
    Write-Host "[1/3] Release build -> SKIPPED (-SkipBuild)" -ForegroundColor Yellow
} else {
    Write-Host "[1/3] Release build..." -ForegroundColor Cyan
    & $msbuild $appProj /t:Build /p:Configuration=Release /p:Platform=AnyCPU /v:minimal
    if ($LASTEXITCODE -ne 0) { Write-Error "MSBuild failed (exit $LASTEXITCODE)"; exit 1 }
    Write-Host "      -> OK" -ForegroundColor Green
}

Write-Host "[2/3] Checking HarvestedFiles.wxs..." -ForegroundColor Cyan

$currentFiles = Get-ChildItem $appBinDir -Recurse -File |
    ForEach-Object { $_.FullName.Substring($appBinDir.Length + 1) } |
    Where-Object { -not (Test-Excluded $_) } |
    Sort-Object

$needHarvest = $ForceHarvest.IsPresent

if (-not $needHarvest) {
    if (-not (Test-Path $harvestOut)) {
        $needHarvest = $true
        Write-Host "      HarvestedFiles.wxs not found -> running harvest" -ForegroundColor Yellow
    } else {
        [xml]$wxs = Get-Content $harvestOut -Encoding UTF8
        $ns = @{ w = "http://wixtoolset.org/schemas/v4/wxs" }
        $existingFiles = Select-Xml -Xml $wxs -XPath "//w:File/@Source" -Namespace $ns |
            ForEach-Object { $_.Node.'#text' -replace '^\$\(var\.AppBinDir\)\\', '' } |
            Sort-Object

        $diff = Compare-Object $currentFiles $existingFiles
        if ($diff) {
            $needHarvest = $true
            Write-Host "      File list changed -> running harvest:" -ForegroundColor Yellow
            $diff | ForEach-Object {
                $label = if ($_.SideIndicator -eq "<=") { "ADD" } else { "DEL" }
                Write-Host "        [$label] $($_.InputObject)"
            }
        } else {
            Write-Host "      No file changes -> harvest skipped (GUIDs unchanged)" -ForegroundColor Green
        }
    }
}

if ($needHarvest) {
    & "$baseDir\run_heat.ps1" -AppBinDir $appBinDir -OutFile $harvestOut
    if ($LASTEXITCODE -ne 0) { Write-Error "Harvest failed (exit $LASTEXITCODE)"; exit 1 }
}

Write-Host "[3/3] Building MSI..." -ForegroundColor Cyan
if ($SuppressValidation) {
    & $msbuild $setupProj /restore /t:Build /p:Configuration=Release /p:Platform=x86 "/p:AppBinDir=$appBinDir" /p:SuppressValidation=true /v:minimal
} else {
    & $msbuild $setupProj /restore /t:Build /p:Configuration=Release /p:Platform=x86 "/p:AppBinDir=$appBinDir" /v:minimal
}
if ($LASTEXITCODE -ne 0) { Write-Error "Setup build failed (exit $LASTEXITCODE)"; exit 1 }

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
if (Test-Path $msiOut) {
    $sizeMB = [math]::Round((Get-Item $msiOut).Length / 1MB, 1)
    Write-Host "Output: $msiOut ($sizeMB MB)" -ForegroundColor Green
} else {
    Write-Warning "MSI not found: $msiOut"
}
