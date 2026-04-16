# Customer churn prediction app launcher
# Usage: .\start-app.ps1

$ErrorActionPreference = "Stop"

$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

Write-Host "========================================" -ForegroundColor $Cyan
Write-Host "  Customer Churn Prediction Launcher" -ForegroundColor $Cyan
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host ""

function Get-PythonCommand {
    try {
        $null = & py -3.11 --version 2>&1
        return $true
    } catch {
        return $false
    }
}

$UsePython311 = Get-PythonCommand

function Invoke-Python {
    param([string[]]$Arguments)

    if ($UsePython311) {
        & py -3.11 @Arguments
    } else {
        & python @Arguments
    }
}

Write-Host "[1/4] Checking Python..." -ForegroundColor $Yellow
try {
    $pythonVersion = Invoke-Python @('--version') 2>&1
    Write-Host "      Found $pythonVersion" -ForegroundColor $Green
} catch {
    Write-Host "      Python not found. Install Python 3.8+ first." -ForegroundColor $Red
    exit 1
}

Write-Host "[2/4] Checking pip..." -ForegroundColor $Yellow
Invoke-Python @('-m', 'pip', '--version') | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "      Found pip" -ForegroundColor $Green
} else {
    Write-Host "      pip not found, bootstrapping it with ensurepip..." -ForegroundColor $Yellow
    Invoke-Python @('-m', 'ensurepip', '--upgrade') | Out-Null
    Invoke-Python @('-m', 'pip', '--version') | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "      pip could not be initialized." -ForegroundColor $Red
        exit 1
    }
    Write-Host "      pip bootstrapped" -ForegroundColor $Green
}

Write-Host "[3/4] Installing dependencies..." -ForegroundColor $Yellow
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$requirementsFile = Join-Path $scriptDir "requirements.txt"

if (Test-Path $requirementsFile) {
    Write-Host "      Installing dependencies, this may take a few minutes..." -ForegroundColor $Yellow
    try {
        Invoke-Python @('-m', 'pip', 'install', '-r', $requirementsFile, '-q')
        Write-Host "      Dependencies installed" -ForegroundColor $Green
    } catch {
        Write-Host "      Dependency installation failed: $_" -ForegroundColor $Red
        exit 1
    }
} else {
    Write-Host "      requirements.txt not found, skipping dependency install" -ForegroundColor $Yellow
}

Write-Host "[4/4] Checking dataset..." -ForegroundColor $Yellow
$dataFile = Join-Path $scriptDir "customerchurn.csv"
if (Test-Path $dataFile) {
    Write-Host "      Found customerchurn.csv" -ForegroundColor $Green
} else {
    Write-Host "      customerchurn.csv not found, the model will try to locate it at startup" -ForegroundColor $Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host "  Starting application..." -ForegroundColor $Cyan
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host ""

Start-Job -ScriptBlock {
    Start-Sleep -Seconds 2
    Start-Process "http://localhost:5001/"
} | Out-Null

Write-Host "  App will run at http://localhost:5001/" -ForegroundColor $Green
Write-Host "  Opening browser..." -ForegroundColor $Yellow
Write-Host "  Press Ctrl+C to stop the service" -ForegroundColor $Red
Write-Host ""

Set-Location $scriptDir
Invoke-Python @('app.py')