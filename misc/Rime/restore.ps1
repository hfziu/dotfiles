param(
    [string]$RimeDir = $(Join-Path $env:APPDATA 'Rime')
)

$ErrorActionPreference = 'Stop'

function Write-Log {
    param(
        [ValidateSet('install', 'update', 'skip', 'error')]
        [string]$Action,
        [string]$Message
    )

    switch ($Action) {
        'install' { Write-Host "  [Installed] $Message" -ForegroundColor Green }
        'update' { Write-Host "  [Updated  ] $Message" -ForegroundColor Yellow }
        'skip' { Write-Host "  [Skipped  ] $Message" }
        'error' { Write-Host "Error: $Message" -ForegroundColor Red }
    }
}

if ($env:OS -ne 'Windows_NT') {
    Write-Host "Current OS ($($env:OS)) is not supported. This script only works on Windows."
    exit 1
}

$scriptDir = $PSScriptRoot

if (-not (Test-Path -LiteralPath $RimeDir -PathType Container)) {
    Write-Log 'error' "Weasel user config directory ($RimeDir) does not exist."
    Write-Host 'Please install Weasel first.'
    exit 1
}

$sourceFiles = Get-ChildItem -LiteralPath $scriptDir -Filter '*.custom.yaml' -File |
    Where-Object { $_.Name -ne 'squirrel.custom.yaml' }

foreach ($file in $sourceFiles) {
    $target = Join-Path $RimeDir $file.Name

    if (Test-Path -LiteralPath $target -PathType Leaf) {
        $sourceHash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
        $targetHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash

        if ($sourceHash -eq $targetHash) {
            Write-Log 'skip' $file.Name
            continue
        }

        Copy-Item -LiteralPath $file.FullName -Destination $target -Force
        Write-Log 'update' $file.Name
        continue
    }

    Copy-Item -LiteralPath $file.FullName -Destination $target
    Write-Log 'install' $file.Name
}

$phraseFile = Join-Path $scriptDir 'custom_phrase_double.txt'
$phraseTarget = Join-Path $RimeDir 'custom_phrase_double.txt'

if (Test-Path -LiteralPath $phraseFile -PathType Leaf) {
    if (Test-Path -LiteralPath $phraseTarget -PathType Leaf) {
        $sourceHash = (Get-FileHash -LiteralPath $phraseFile -Algorithm SHA256).Hash
        $targetHash = (Get-FileHash -LiteralPath $phraseTarget -Algorithm SHA256).Hash

        if ($sourceHash -eq $targetHash) {
            Write-Log 'skip' 'custom_phrase_double.txt'
        }
        else {
            $response = Read-Host 'custom_phrase_double.txt already exists. Override it? [y/N]'
            if ($response -match '^[Yy]$') {
                Copy-Item -LiteralPath $phraseFile -Destination $phraseTarget -Force
                Write-Log 'update' 'custom_phrase_double.txt'
            }
            else {
                Write-Log 'skip' 'custom_phrase_double.txt'
            }
        }
    }
    else {
        Copy-Item -LiteralPath $phraseFile -Destination $phraseTarget
        Write-Log 'install' 'custom_phrase_double.txt'
    }
}