param(
    [string]$MongoShellPath = "mongosh",
    [string]$MongoHost = "localhost",
    [int]$MongoPort = 27017,
    [string]$AdminDatabase = "admin",
    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "123456",
    [string]$Database = "ntss",
    [string]$AppUsername = "nkk",
    [string]$AppPassword = "nkk",
    [switch]$RecreateDatabase
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mongoJs = Join-Path $scriptDir "mongo\\init_ntss.js"

if (-not (Test-Path $mongoJs)) {
    throw "Mongo JS script not found: $mongoJs"
}

if (($AdminUsername -and -not $AdminPassword) -or (-not $AdminUsername -and $AdminPassword)) {
    throw "Mongo admin username/password must be provided together"
}

$env:MONGO_DB_NAME = $Database
$env:MONGO_APP_USER = $AppUsername
$env:MONGO_APP_PASSWORD = $AppPassword
$env:MONGO_RECREATE_DB = if ($RecreateDatabase) { "true" } else { "false" }

try {
    $args = @(
        "--quiet",
        "--host", $MongoHost,
        "--port", $MongoPort,
        "--file", $mongoJs
    )

    if ($AdminUsername) {
        $args += @(
            "--username", $AdminUsername,
            "--password", $AdminPassword,
            "--authenticationDatabase", $AdminDatabase
        )
    }

    Write-Host "[init][mongo] shell=$MongoShellPath host=$MongoHost port=$MongoPort authDb=$AdminDatabase"
    Write-Host "[init][mongo] target db=$Database appUser=$AppUsername recreateDb=$($RecreateDatabase.IsPresent)"

    & $MongoShellPath @args
    if ($LASTEXITCODE -ne 0) {
        throw "mongosh exited with code $LASTEXITCODE"
    }
}
finally {
    Remove-Item Env:MONGO_DB_NAME -ErrorAction SilentlyContinue
    Remove-Item Env:MONGO_APP_USER -ErrorAction SilentlyContinue
    Remove-Item Env:MONGO_APP_PASSWORD -ErrorAction SilentlyContinue
    Remove-Item Env:MONGO_RECREATE_DB -ErrorAction SilentlyContinue
}

Write-Host "[init][mongo] complete: $Database"
