param(
    [string]$AppBinDir = "D:\ntss\ntss-win_copy_V2.0A\FNSICloudConvert\FNSICloudConvertClient\FNSICloudConvertClient\bin\Release",
    [string]$OutFile = "D:\ntss\ntss-win_copy_V2.0A\FNSICloudConvert\FNSICloudConvertClient\Setup\Generated\HarvestedFiles.wxs"
)

$ErrorActionPreference = "Stop"

$excludePatterns = @(
    '^LOG($|\\)',
    '^DbMigrationTool\.exe$',
    '^DbMigrationTool\.exe\.config$',
    '^DbMigrationTool\.pdb$',
    '^user_settings\.json$',
    '\.log$',
    '\.pdb$',
    '\.xml$'
)

function Test-Excluded([string]$relativePath) {
    foreach ($pattern in $excludePatterns) {
        if ($relativePath -match $pattern) {
            return $true
        }
    }

    return $false
}

function Get-StableGuid([string]$text) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text.ToLowerInvariant())
    $md5 = [System.Security.Cryptography.MD5]::Create()

    try {
        $hash = $md5.ComputeHash($bytes)
        return ([Guid]::new($hash)).ToString("B").ToUpperInvariant()
    }
    finally {
        $md5.Dispose()
    }
}

function Get-StableId([string]$prefix, [string]$text) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text.ToLowerInvariant())
    $sha1 = [System.Security.Cryptography.SHA1]::Create()

    try {
        $hash = [System.BitConverter]::ToString($sha1.ComputeHash($bytes)).Replace("-", "")
        return "{0}_{1}" -f $prefix, $hash.Substring(0, 24)
    }
    finally {
        $sha1.Dispose()
    }
}

function Escape-Xml([string]$text) {
    return [System.Security.SecurityElement]::Escape($text)
}

if (-not (Test-Path -LiteralPath $AppBinDir)) {
    throw "AppBinDir was not found: $AppBinDir"
}

$files = Get-ChildItem -LiteralPath $AppBinDir -Recurse -File |
    ForEach-Object { $_.FullName.Substring($AppBinDir.Length + 1) } |
    ForEach-Object { $_ -replace '/', '\' } |
    Where-Object { -not (Test-Excluded $_) } |
    Sort-Object

if (-not $files -or $files.Count -eq 0) {
    throw "No files were found to harvest under '$AppBinDir'."
}

$filesByDir = @{}
$childDirsByParent = @{}

function Normalize-Dir([string]$dir) {
    if ([string]::IsNullOrEmpty($dir) -or $dir -eq ".") {
        return ""
    }

    return $dir
}

function Add-ChildDir([string]$parent, [string]$child) {
    if (-not $childDirsByParent.ContainsKey($parent)) {
        $childDirsByParent[$parent] = @{}
    }

    $childDirsByParent[$parent][$child] = $true
}

foreach ($relativePath in $files) {
    $dir = Normalize-Dir (Split-Path -Path $relativePath -Parent)

    if (-not $filesByDir.ContainsKey($dir)) {
        $filesByDir[$dir] = New-Object System.Collections.Generic.List[string]
    }

    $filesByDir[$dir].Add($relativePath)

    $current = $dir
    while (-not [string]::IsNullOrEmpty($current)) {
        $parent = Normalize-Dir (Split-Path -Path $current -Parent)
        Add-ChildDir $parent $current
        $current = $parent
    }
}

$componentIds = New-Object System.Collections.Generic.List[string]
$lines = New-Object System.Collections.Generic.List[string]

function Add-Line([string]$text) {
    $lines.Add($text) | Out-Null
}

function Write-DirectoryContent([string]$dir, [int]$indent) {
    $indentText = " " * $indent

    if ($filesByDir.ContainsKey($dir)) {
        foreach ($relativePath in ($filesByDir[$dir] | Sort-Object)) {
            $componentId = Get-StableId "Cmp" $relativePath
            $fileId = Get-StableId "File" $relativePath
            $guid = Get-StableGuid $relativePath
            $source = '$(var.AppBinDir)\' + $relativePath

            Add-Line ($indentText + "<Component Id=`"$componentId`" Guid=`"$guid`">")
            Add-Line ((" " * ($indent + 2)) + "<File Id=`"$fileId`" KeyPath=`"yes`" Source=`"" + (Escape-Xml $source) + "`" />")
            Add-Line ($indentText + "</Component>")
            $componentIds.Add($componentId) | Out-Null
        }
    }

    if ($childDirsByParent.ContainsKey($dir)) {
        foreach ($childDir in ($childDirsByParent[$dir].Keys | Sort-Object)) {
            $directoryId = Get-StableId "Dir" $childDir
            $directoryName = Split-Path -Path $childDir -Leaf

            Add-Line ($indentText + "<Directory Id=`"$directoryId`" Name=`"" + (Escape-Xml $directoryName) + "`">")
            Write-DirectoryContent $childDir ($indent + 2)
            Add-Line ($indentText + "</Directory>")
        }
    }
}

Add-Line '<Wix xmlns="http://wixtoolset.org/schemas/v4/wxs">'
Add-Line '  <Fragment>'
Add-Line '    <DirectoryRef Id="INSTALLFOLDER">'
Write-DirectoryContent "" 6
Add-Line '    </DirectoryRef>'
Add-Line '  </Fragment>'
Add-Line '  <Fragment>'
Add-Line '    <ComponentGroup Id="HarvestedComponents">'

foreach ($componentId in ($componentIds | Sort-Object)) {
    Add-Line ("      <ComponentRef Id=`"$componentId`" />")
}

Add-Line '    </ComponentGroup>'
Add-Line '  </Fragment>'
Add-Line '</Wix>'

$outDir = Split-Path -Path $OutFile -Parent
if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

[System.IO.File]::WriteAllLines($OutFile, $lines, [System.Text.UTF8Encoding]::new($false))

Write-Host "Harvested $($componentIds.Count) files into $OutFile" -ForegroundColor Green
