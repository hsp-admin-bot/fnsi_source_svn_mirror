param(
    [string]$SourceRoot = "C:\FNW\Source",
    [string]$TargetRoot = $PSScriptRoot,
    [switch]$NoDelete,
    [switch]$DryRun,
    [switch]$ForcePowerShellMatcher
)

$ErrorActionPreference = "Stop"

try {
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
} catch {
    # Keep going on hosts that do not allow changing console encoding.
}

$script:LastMeterLength = 0

function Write-Info {
    param(
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::Gray
    )

    Write-Host $Message -ForegroundColor $Color
}

function Resolve-DirectoryPath {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Directory not found: $Path"
    }

    return (Resolve-Path -LiteralPath $Path).Path.TrimEnd("\")
}

function Normalize-RelativePath {
    param([string]$Path)

    $normalized = $Path -replace "\\", "/"
    while ($normalized.StartsWith("./")) {
        $normalized = $normalized.Substring(2)
    }
    return $normalized.TrimStart("/")
}

function Get-RelativePath {
    param(
        [string]$Root,
        [string]$FullName
    )

    $rootWithSlash = $Root.TrimEnd("\") + "\"
    if (-not $FullName.StartsWith($rootWithSlash, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside root: $FullName"
    }

    return Normalize-RelativePath $FullName.Substring($rootWithSlash.Length)
}

function Write-Meter {
    param(
        [string]$Activity,
        [int]$Done,
        [int]$Total,
        [string]$Detail = ""
    )

    if ($Total -le 0) {
        $line = ("{0} [------------------------------]   0% 0/0 {1}" -f $Activity, $Detail)
    } else {
        $percent = [Math]::Floor(($Done * 100.0) / $Total)
        if ($percent -gt 100) { $percent = 100 }
        $width = 30
        $filled = [Math]::Floor(($percent * $width) / 100)
        $bar = ("#" * $filled).PadRight($width, "-")
        $line = ("{0} [{1}] {2,3}% {3}/{4} {5}" -f $Activity, $bar, $percent, $Done, $Total, $Detail)
    }

    $padLength = [Math]::Max(0, $script:LastMeterLength - $line.Length)
    Write-Host -NoNewline ("`r" + $line + (" " * $padLength))
    $script:LastMeterLength = $line.Length

    if ($Done -ge $Total) {
        Write-Host ""
        $script:LastMeterLength = 0
    }
}

function Convert-GlobBodyToRegex {
    param([string]$Pattern)

    $builder = New-Object System.Text.StringBuilder
    $i = 0

    while ($i -lt $Pattern.Length) {
        $char = $Pattern[$i]

        if ($char -eq "*") {
            if (($i + 1) -lt $Pattern.Length -and $Pattern[$i + 1] -eq "*") {
                $i += 2
                if ($i -lt $Pattern.Length -and $Pattern[$i] -eq "/") {
                    [void]$builder.Append("(?:.*/)?")
                    $i += 1
                } else {
                    [void]$builder.Append(".*")
                }
                continue
            }

            [void]$builder.Append("[^/]*")
            $i += 1
            continue
        }

        if ($char -eq "?") {
            [void]$builder.Append("[^/]")
            $i += 1
            continue
        }

        if ($char -eq "[") {
            $end = $Pattern.IndexOf("]", $i + 1)
            if ($end -gt $i) {
                $content = $Pattern.Substring($i + 1, $end - $i - 1)
                if ($content.StartsWith("!")) {
                    $content = "^" + [Regex]::Escape($content.Substring(1))
                } else {
                    $content = [Regex]::Escape($content)
                    $content = $content -replace "\\-", "-"
                }
                [void]$builder.Append("[" + $content + "]")
                $i = $end + 1
                continue
            }
        }

        [void]$builder.Append([Regex]::Escape([string]$char))
        $i += 1
    }

    return $builder.ToString()
}

function Convert-IgnorePatternToRegex {
    param([string]$Pattern)

    $patternText = ($Pattern -replace "\\", "/").Trim()
    if ([string]::IsNullOrWhiteSpace($patternText)) { return $null }

    $anchored = $false
    if ($patternText.StartsWith("/")) {
        $anchored = $true
        $patternText = $patternText.Substring(1)
    }

    $directoryPattern = $false
    if ($patternText.EndsWith("/")) {
        $directoryPattern = $true
        $patternText = $patternText.TrimEnd("/")
    }

    if ([string]::IsNullOrWhiteSpace($patternText)) { return $null }

    $body = Convert-GlobBodyToRegex $patternText
    if ($anchored) {
        $prefix = "^"
    } else {
        $prefix = "^(?:.*/)?"
    }

    if ($directoryPattern) {
        return $prefix + $body + "(?:/.*)?$"
    }

    return $prefix + $body + "$"
}

function Get-AugmentIgnoreRules {
    param([string]$RootPath)

    $ignorePath = Join-Path $RootPath ".augmentignore"
    $rules = New-Object System.Collections.ArrayList

    if (-not (Test-Path -LiteralPath $ignorePath -PathType Leaf)) {
        return $rules
    }

    $lines = Get-Content -LiteralPath $ignorePath -Encoding UTF8
    foreach ($line in $lines) {
        $raw = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($raw)) { continue }
        if ($raw.StartsWith("#")) { continue }

        $include = $false
        $pattern = $raw
        if ($pattern.StartsWith("!")) {
            $include = $true
            $pattern = $pattern.Substring(1)
        }

        $regex = Convert-IgnorePatternToRegex $pattern
        if (-not [string]::IsNullOrWhiteSpace($regex)) {
            [void]$rules.Add([PSCustomObject]@{
                Pattern = $pattern
                Regex = $regex
                IsInclude = $include
            })
        }
    }

    return $rules
}

function Test-AugmentIgnored {
    param(
        [string]$RelativePath,
        [System.Collections.ArrayList]$Rules
    )

    $path = Normalize-RelativePath $RelativePath
    $ignored = $false

    foreach ($rule in $Rules) {
        if ([Regex]::IsMatch($path, $rule.Regex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            $ignored = -not $rule.IsInclude
        }
    }

    return $ignored
}

function Get-TargetFilesWithRipgrep {
    param(
        [string]$RootPath,
        [string]$IgnorePath
    )

    if ($ForcePowerShellMatcher) { return $null }

    $rg = Get-Command rg -ErrorAction SilentlyContinue
    if (-not $rg) { return $null }

    $files = New-Object System.Collections.Generic.List[string]
    Push-Location $RootPath
    try {
        $rgArgs = @(
            "--files",
            "--hidden",
            "--ignore-file", $IgnorePath,
            "--no-ignore-parent",
            "--no-ignore-vcs",
            "--no-ignore-dot",
            "--no-ignore-global"
        )

        $output = & $rg.Source @rgArgs
        $exitCode = $LASTEXITCODE
        if ($exitCode -gt 1) {
            throw "rg failed with exit code $exitCode"
        }

        foreach ($line in $output) {
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                $files.Add((Normalize-RelativePath $line))
            }
        }
    } finally {
        Pop-Location
    }

    return $files
}

function Get-TargetFilesWithPowerShell {
    param(
        [string]$RootPath,
        [System.Collections.ArrayList]$Rules
    )

    $files = New-Object System.Collections.Generic.List[string]
    $items = Get-ChildItem -LiteralPath $RootPath -Recurse -File -Force
    $done = 0
    $total = @($items).Count

    foreach ($item in $items) {
        $done += 1
        if (($done % 500) -eq 0 -or $done -eq $total) {
            Write-Meter "Scan" $done $total
        }

        $relativePath = Get-RelativePath -Root $RootPath -FullName $item.FullName
        if (-not (Test-AugmentIgnored -RelativePath $relativePath -Rules $Rules)) {
            $files.Add($relativePath)
        }
    }

    return $files
}

function Test-ProtectedTargetPath {
    param([string]$RelativePath)

    $path = Normalize-RelativePath $RelativePath
    $protectedPrefixes = @(
        ".git/",
        ".agents/",
        ".codex/"
    )
    $protectedFiles = @(
        "Mirror-Source.ps1",
        "Mirror-Source.bat"
    )

    foreach ($prefix in $protectedPrefixes) {
        if ($path.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    foreach ($file in $protectedFiles) {
        if ($path.Equals($file, [StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Test-CopyRequired {
    param(
        [System.IO.FileInfo]$SourceInfo,
        [string]$DestinationPath
    )

    if (-not (Test-Path -LiteralPath $DestinationPath -PathType Leaf)) {
        return $true
    }

    $destinationInfo = Get-Item -LiteralPath $DestinationPath -Force
    if ($destinationInfo.Length -ne $SourceInfo.Length) {
        return $true
    }

    $delta = [Math]::Abs(($destinationInfo.LastWriteTimeUtc - $SourceInfo.LastWriteTimeUtc).TotalSeconds)
    return ($delta -gt 2)
}

function Copy-OneFile {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [System.IO.FileInfo]$SourceInfo
    )

    $parent = Split-Path -Parent $DestinationPath
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        [void](New-Item -Path $parent -ItemType Directory -Force)
    }

    if (Test-Path -LiteralPath $DestinationPath -PathType Leaf) {
        $destinationInfo = Get-Item -LiteralPath $DestinationPath -Force
        if (($destinationInfo.Attributes -band [System.IO.FileAttributes]::ReadOnly) -ne 0) {
            $destinationInfo.Attributes = $destinationInfo.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly)
        }
    }

    [System.IO.File]::Copy($SourcePath, $DestinationPath, $true)
    [System.IO.File]::SetLastWriteTimeUtc($DestinationPath, $SourceInfo.LastWriteTimeUtc)
}

function Remove-EmptyDirectories {
    param([string]$RootPath)

    $directories = Get-ChildItem -LiteralPath $RootPath -Directory -Recurse -Force |
        Sort-Object -Property FullName -Descending

    foreach ($directory in $directories) {
        $relativePath = Get-RelativePath -Root $RootPath -FullName $directory.FullName
        if (Test-ProtectedTargetPath ($relativePath + "/")) {
            continue
        }

        $children = Get-ChildItem -LiteralPath $directory.FullName -Force -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $children) {
            Remove-Item -LiteralPath $directory.FullName -Force
        }
    }
}

$startedAt = Get-Date
$sourcePath = Resolve-DirectoryPath $SourceRoot
$targetPath = Resolve-DirectoryPath $TargetRoot

if ($sourcePath.Equals($targetPath, [StringComparison]::OrdinalIgnoreCase)) {
    throw "SourceRoot and TargetRoot must be different."
}

$sourceWithSlash = $sourcePath.TrimEnd("\") + "\"
if ($targetPath.StartsWith($sourceWithSlash, [StringComparison]::OrdinalIgnoreCase)) {
    throw "TargetRoot must not be inside SourceRoot."
}

$ignorePath = Join-Path $sourcePath ".augmentignore"
if (-not (Test-Path -LiteralPath $ignorePath -PathType Leaf)) {
    throw ".augmentignore not found: $ignorePath"
}

$rules = Get-AugmentIgnoreRules -RootPath $sourcePath

Write-Info "Mirror Source repository files" Cyan
Write-Info ("Source : {0}" -f $sourcePath)
Write-Info ("Target : {0}" -f $targetPath)
Write-Info (".augmentignore rules: {0}" -f $rules.Count)
Write-Info ("Delete stale files : {0}" -f (-not $NoDelete))
Write-Info ("Dry run            : {0}" -f [bool]$DryRun)
Write-Info ""

Write-Info "Building target file list..." Yellow
$targetFiles = Get-TargetFilesWithRipgrep -RootPath $sourcePath -IgnorePath $ignorePath
if ($null -eq $targetFiles) {
    Write-Info "rg is unavailable or disabled. Using PowerShell matcher." Yellow
    $targetFiles = Get-TargetFilesWithPowerShell -RootPath $sourcePath -Rules $rules
} else {
    Write-Info "Using rg matcher." DarkGray
}

$desiredSet = New-Object "System.Collections.Generic.HashSet[string]" ([StringComparer]::OrdinalIgnoreCase)
foreach ($relativePath in $targetFiles) {
    [void]$desiredSet.Add((Normalize-RelativePath $relativePath))
}

Write-Info ("Target files: {0}" -f $targetFiles.Count)
Write-Info ""

$copied = 0
$skipped = 0
$failed = 0
$copyErrors = New-Object System.Collections.ArrayList
$done = 0
$copyTotal = $targetFiles.Count

foreach ($relativePath in $targetFiles) {
    $done += 1
    $sourceFile = Join-Path $sourcePath ($relativePath -replace "/", "\")
    $destinationFile = Join-Path $targetPath ($relativePath -replace "/", "\")

    try {
        $sourceInfo = Get-Item -LiteralPath $sourceFile -Force
        if (Test-CopyRequired -SourceInfo $sourceInfo -DestinationPath $destinationFile) {
            if (-not $DryRun) {
                Copy-OneFile -SourcePath $sourceFile -DestinationPath $destinationFile -SourceInfo $sourceInfo
            }
            $copied += 1
        } else {
            $skipped += 1
        }
    } catch {
        $failed += 1
        [void]$copyErrors.Add(("COPY FAILED: {0} :: {1}" -f $relativePath, $_.Exception.Message))
    }

    if (($done % 100) -eq 0 -or $done -eq $copyTotal) {
        Write-Meter "Copy" $done $copyTotal ("copied={0} skipped={1} failed={2}" -f $copied, $skipped, $failed)
    }
}

$deleted = 0
$deleteFailed = 0
$deleteErrors = New-Object System.Collections.ArrayList

if (-not $NoDelete) {
    Write-Info ""
    Write-Info "Checking stale files..." Yellow
    $targetItems = Get-ChildItem -LiteralPath $targetPath -Recurse -File -Force
    $staleFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]

    foreach ($item in $targetItems) {
        $relativePath = Get-RelativePath -Root $targetPath -FullName $item.FullName
        if (Test-ProtectedTargetPath $relativePath) {
            continue
        }
        if (-not $desiredSet.Contains((Normalize-RelativePath $relativePath))) {
            $staleFiles.Add($item)
        }
    }

    $deleteTotal = $staleFiles.Count
    $deleteDone = 0
    foreach ($item in $staleFiles) {
        $deleteDone += 1
        $relativePath = Get-RelativePath -Root $targetPath -FullName $item.FullName

        try {
            if (-not $DryRun) {
                if (($item.Attributes -band [System.IO.FileAttributes]::ReadOnly) -ne 0) {
                    $item.Attributes = $item.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly)
                }
                Remove-Item -LiteralPath $item.FullName -Force
            }
            $deleted += 1
        } catch {
            $deleteFailed += 1
            [void]$deleteErrors.Add(("DELETE FAILED: {0} :: {1}" -f $relativePath, $_.Exception.Message))
        }

        if (($deleteDone % 100) -eq 0 -or $deleteDone -eq $deleteTotal) {
            Write-Meter "Delete" $deleteDone $deleteTotal ("deleted={0} failed={1}" -f $deleted, $deleteFailed)
        }
    }

    if ($deleteTotal -eq 0) {
        Write-Meter "Delete" 0 0 "deleted=0 failed=0"
    }

    if (-not $DryRun) {
        Remove-EmptyDirectories -RootPath $targetPath
    }
}

$elapsed = (Get-Date) - $startedAt
Write-Info ""
Write-Info "Finished" Cyan
Write-Info ("Copied/updated : {0}" -f $copied)
Write-Info ("Skipped        : {0}" -f $skipped)
Write-Info ("Deleted stale  : {0}" -f $deleted)
Write-Info ("Copy failed    : {0}" -f $failed)
Write-Info ("Delete failed  : {0}" -f $deleteFailed)
Write-Info ("Elapsed        : {0:hh\:mm\:ss}" -f $elapsed)

if ($copyErrors.Count -gt 0 -or $deleteErrors.Count -gt 0) {
    Write-Info ""
    Write-Info "Errors:" Red
    $copyErrors | Select-Object -First 20 | ForEach-Object { Write-Info $_ Red }
    $deleteErrors | Select-Object -First 20 | ForEach-Object { Write-Info $_ Red }
    if (($copyErrors.Count + $deleteErrors.Count) -gt 20) {
        Write-Info "Only first 20 errors are shown." Red
    }
    exit 1
}

exit 0
