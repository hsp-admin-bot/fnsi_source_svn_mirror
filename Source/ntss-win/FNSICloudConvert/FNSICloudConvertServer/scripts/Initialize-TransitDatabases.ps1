param(
    [string]$PsqlPath = "C:\Program Files\PostgreSQL\16\bin\psql.exe",
    [string]$dbHost = "localhost",
    [int]$Port = 5433,
    [string]$Username = "postgres",
    [string]$AdminDatabase = "postgres",
    [string]$Password = "",
    [switch]$SkipMongoInit,
    [string]$MongoShellPath = "mongosh",
    [string]$MongoHost = "localhost",
    [int]$MongoPort = 27018,
    [string]$MongoAdminDatabase = "admin",
    [string]$MongoAdminUsername = "admin",
    [string]$MongoAdminPassword = "123456",
    [string]$MongoDatabase = "ntss",
    [string]$MongoAppUsername = "nkk",
    [string]$MongoAppPassword = "nkk",
    [switch]$MongoRecreateDatabase
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlFile = Join-Path $scriptDir "sql\\init_all_databases.sql"

if (-not (Test-Path $sqlFile)) {
    throw "SQL script not found: $sqlFile"
}

if ($Password) {
    $env:PGPASSWORD = $Password
}

$env:PGCLIENTENCODING = "UTF8"
try {
    Write-Host "[init] admin login: host=$dbHost port=$Port user=$Username db=$AdminDatabase"
    Write-Host "[init] target roles: convert_db=nkk, ntss_db4=nkk4, ntss_db5=nkk5, ntss_db6=nkk6"
    & $PsqlPath -h $dbHost -p $Port -U $Username -d $AdminDatabase -f $sqlFile
    if ($LASTEXITCODE -ne 0) {
        throw "psql exited with code $LASTEXITCODE"
    }

    if (-not $SkipMongoInit) {
        $mongoScript = Join-Path $scriptDir "Initialize-TransitMongo.ps1"
        if (-not (Test-Path $mongoScript)) {
            throw "Mongo init script not found: $mongoScript"
        }
        & $mongoScript `
            -MongoShellPath $MongoShellPath `
            -MongoHost $MongoHost `
            -MongoPort $MongoPort `
            -AdminDatabase $MongoAdminDatabase `
            -AdminUsername $MongoAdminUsername `
            -AdminPassword $MongoAdminPassword `
            -Database $MongoDatabase `
            -AppUsername $MongoAppUsername `
            -AppPassword $MongoAppPassword `
            -RecreateDatabase:$MongoRecreateDatabase
        if ($LASTEXITCODE -ne 0) {
            throw "Mongo init script exited with code $LASTEXITCODE"
        }
    }
}
finally {
    if ($Password) {
        Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
    }
}

Write-Host "[init] complete: convert_db(V1/V2/V3), ntss_db4(schema only), ntss_db5(schema only), ntss_db6(schema only), mongo=$MongoDatabase"
