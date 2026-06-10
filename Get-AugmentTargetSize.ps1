param(
    [string]$Root = ".",
    [string]$OutputCsv = ".\augment-index-target-files-nonGit.csv",
    [switch]$ShowTopDirs
)

$ErrorActionPreference = "Stop"

function Resolve-FullPath {
    param([string]$Path)
    return (Resolve-Path $Path).Path
}

function Format-Size {
    param([Int64]$Bytes)
    if ($Bytes -ge 1TB) { return "{0:N2} TB" -f ($Bytes / 1TB) }
    elseif ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    elseif ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    elseif ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    else { return "$Bytes B" }
}

function Convert-PatternToRegex {
    param([string]$Pattern)

    if ([string]::IsNullOrWhiteSpace($Pattern)) { return $null }
    if ($Pattern.TrimStart().StartsWith("#")) { return $null }

    $isDirectoryPattern = $false
    if ($Pattern.EndsWith("/")) {
        $isDirectoryPattern = $true
        $Pattern = $Pattern.TrimEnd("/")
    }

    $anchoredToRoot = $false
    if ($Pattern.StartsWith("/")) {
        $anchoredToRoot = $true
        $Pattern = $Pattern.Substring(1)
    }

    $patternWin = $Pattern.Replace("/", "\")
    $escaped = [Regex]::Escape($patternWin)

    $escaped = $escaped -replace "\\\*\\\*", "__DOUBLESTAR__"
    $escaped = $escaped -replace "\\\*", "[^\\]*"
    $escaped = $escaped -replace "__DOUBLESTAR__", ".*"

    if ($isDirectoryPattern) {
        if ($anchoredToRoot) {
            return "^" + $escaped + "(\\.*)?$"
        } else {
            return "^(.*\\)?" + $escaped + "(\\.*)?$"
        }
    } else {
        if ($anchoredToRoot) {
            return "^" + $escaped + "$"
        } else {
            return "^(.*\\)?" + $escaped + "$"
        }
    }
}

function Get-AugmentIgnoreRules {
    param([string]$RootPath)

    $augmentIgnorePath = Join-Path $RootPath ".augmentignore"
    $rules = New-Object System.Collections.ArrayList

    if (-not (Test-Path $augmentIgnorePath)) {
        return $rules
    }

    $lines = Get-Content $augmentIgnorePath -Encoding UTF8
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

        $regex = Convert-PatternToRegex -Pattern $pattern
        if (-not [string]::IsNullOrWhiteSpace($regex)) {
            [void]$rules.Add([PSCustomObject]@{
                Pattern   = $pattern
                Regex     = $regex
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

    if (-not $Rules -or $Rules.Count -eq 0) {
        return $false
    }

    $isIgnored = $false

    foreach ($rule in $Rules) {
        if ([Regex]::IsMatch($RelativePath, $rule.Regex)) {
            if ($rule.IsInclude) {
                $isIgnored = $false
            } else {
                $isIgnored = $true
            }
        }
    }

    return $isIgnored
}

$rootPath = Resolve-FullPath $Root
Set-Location $rootPath

$rules = Get-AugmentIgnoreRules -RootPath $rootPath

if ($rules.Count -gt 0) {
    $augmentIgnoreStatus = "found ($($rules.Count) rules)"
} else {
    $augmentIgnoreStatus = "not found"
}

Write-Host "Root          : $rootPath"
Write-Host ".augmentignore: $augmentIgnoreStatus"
Write-Host ""

$allFiles = Get-ChildItem -Path "." -Recurse -File -Force

$fileObjects = New-Object System.Collections.ArrayList

foreach ($item in $allFiles) {
    $relPath = $item.FullName.Substring($rootPath.Length).TrimStart("\")
    $relPath = $relPath -replace "/", "\"

    if (Test-AugmentIgnored -RelativePath $relPath -Rules $rules) {
        continue
    }

    [void]$fileObjects.Add([PSCustomObject]@{
        RelativePath = $relPath
        Extension    = if ([string]::IsNullOrWhiteSpace($item.Extension)) { "[no extension]" } else { $item.Extension.ToLower() }
        SizeBytes    = [Int64]$item.Length
        SizeKB       = [math]::Round($item.Length / 1KB, 2)
        Directory    = Split-Path $relPath -Parent
    })
}

$totalFiles = $fileObjects.Count

if ($totalFiles -gt 0) {
    $totalBytes = ($fileObjects | Measure-Object -Property SizeBytes -Sum).Sum
} else {
    $totalBytes = 0
}

$extSummary = $fileObjects |
    Group-Object Extension |
    ForEach-Object {
        $sum = ($_.Group | Measure-Object -Property SizeBytes -Sum).Sum
        [PSCustomObject]@{
            Extension = $_.Name
            Files     = $_.Count
            TotalMB   = [math]::Round(($sum / 1MB), 2)
        }
    } |
    Sort-Object -Property `
        @{ Expression = "Files"; Descending = $true }, `
        @{ Expression = "TotalMB"; Descending = $true }

$fileObjects |
    Sort-Object -Property @{ Expression = "SizeBytes"; Descending = $true } |
    Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "=== Augment Code インデックス対象 推定結果 (non-Git) ===" -ForegroundColor Cyan
Write-Host "Target Files : $totalFiles"
Write-Host "Total Size   : $(Format-Size $totalBytes)"
Write-Host "CSV Output   : $OutputCsv"
Write-Host ""

Write-Host "--- 拡張子別 上位20 ---" -ForegroundColor Yellow
$extSummary | Select-Object -First 20 | Format-Table -AutoSize

if ($ShowTopDirs) {
    Write-Host ""
    Write-Host "--- ディレクトリ別 上位20 ---" -ForegroundColor Yellow

    $dirSummary = $fileObjects |
        Group-Object Directory |
        ForEach-Object {
            $sum = ($_.Group | Measure-Object -Property SizeBytes -Sum).Sum
            [PSCustomObject]@{
                Directory = if ([string]::IsNullOrWhiteSpace($_.Name)) { "." } else { $_.Name }
                Files     = $_.Count
                TotalMB   = [math]::Round(($sum / 1MB), 2)
            }
        } |
        Sort-Object -Property `
            @{ Expression = "TotalMB"; Descending = $true }, `
            @{ Expression = "Files"; Descending = $true }

    $dirSummary | Select-Object -First 20 | Format-Table -AutoSize
}