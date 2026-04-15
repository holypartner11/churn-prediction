# 客户流失预测系统启动脚本
# 用法: .\start-app.ps1

$ErrorActionPreference = "Stop"

# 颜色定义
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

Write-Host "========================================" -ForegroundColor $Cyan
Write-Host "  客户流失预测系统启动器" -ForegroundColor $Cyan
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host ""

# 检查 Python
Write-Host "[1/4] 检查 Python 环境..." -ForegroundColor $Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "      ✓ 找到 $pythonVersion" -ForegroundColor $Green
} catch {
    Write-Host "      ✗ 未找到 Python，请安装 Python 3.8+" -ForegroundColor $Red
    exit 1
}

# 检查 pip
Write-Host "[2/4] 检查 pip..." -ForegroundColor $Yellow
try {
    $pipVersion = pip --version 2>&1
    Write-Host "      ✓ 找到 pip" -ForegroundColor $Green
} catch {
    Write-Host "      ✗ 未找到 pip" -ForegroundColor $Red
    exit 1
}

# 检查并安装依赖
Write-Host "[3/4] 检查依赖..." -ForegroundColor $Yellow
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$requirementsFile = Join-Path $scriptDir "requirements.txt"

if (Test-Path $requirementsFile) {
    Write-Host "      正在安装依赖（可能需要几分钟）..." -ForegroundColor $Yellow
    try {
        pip install -r $requirementsFile -q
        Write-Host "      ✓ 依赖安装完成" -ForegroundColor $Green
    } catch {
        Write-Host "      ✗ 依赖安装失败: $_" -ForegroundColor $Red
        exit 1
    }
} else {
    Write-Host "      ! 未找到 requirements.txt，跳过依赖检查" -ForegroundColor $Yellow
}

# 检查数据文件
Write-Host "[4/4] 检查数据文件..." -ForegroundColor $Yellow
$dataFile = Join-Path $scriptDir "customerchurn.csv"
if (Test-Path $dataFile) {
    Write-Host "      ✓ 找到 customerchurn.csv" -ForegroundColor $Green
} else {
    Write-Host "      ! 未找到 customerchurn.csv，模型将在启动时尝试查找" -ForegroundColor $Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host "  启动应用..." -ForegroundColor $Cyan
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host ""

# 启动浏览器（延迟2秒确保服务启动）
Start-Job -ScriptBlock {
    Start-Sleep -Seconds 2
    Start-Process "http://localhost:5001/"
} | Out-Null

Write-Host "  应用将在 http://localhost:5001/ 运行" -ForegroundColor $Green
Write-Host "  正在打开浏览器..." -ForegroundColor $Yellow
Write-Host "  按 Ctrl+C 停止服务" -ForegroundColor $Red
Write-Host ""

# 启动 Flask 应用
$appFile = Join-Path $scriptDir "app.py"
Set-Location $scriptDir
python app.py
