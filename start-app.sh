#!/bin/bash

# 客户流失预测系统启动脚本
# 用法: ./start-app.sh

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  客户流失预测系统启动器${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 检查 Python
echo -e "${YELLOW}[1/4] 检查 Python 环境...${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    PYTHON_VERSION=$($PYTHON_CMD --version 2>&1)
    echo -e "${GREEN}      ✓ 找到 $PYTHON_VERSION${NC}"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
    PYTHON_VERSION=$($PYTHON_CMD --version 2>&1)
    echo -e "${GREEN}      ✓ 找到 $PYTHON_VERSION${NC}"
else
    echo -e "${RED}      ✗ 未找到 Python，请安装 Python 3.8+${NC}"
    exit 1
fi

# 检查 pip
echo -e "${YELLOW}[2/4] 检查 pip...${NC}"
if command -v pip3 &> /dev/null; then
    PIP_CMD="pip3"
    echo -e "${GREEN}      ✓ 找到 pip3${NC}"
elif command -v pip &> /dev/null; then
    PIP_CMD="pip"
    echo -e "${GREEN}      ✓ 找到 pip${NC}"
else
    echo -e "${RED}      ✗ 未找到 pip${NC}"
    exit 1
fi

# 检查并安装依赖
echo -e "${YELLOW}[3/4] 检查依赖...${NC}"
REQUIREMENTS_FILE="$SCRIPT_DIR/requirements.txt"

if [ -f "$REQUIREMENTS_FILE" ]; then
    echo -e "${YELLOW}      正在安装依赖（可能需要几分钟）...${NC}"
    if $PIP_CMD install -r "$REQUIREMENTS_FILE" -q; then
        echo -e "${GREEN}      ✓ 依赖安装完成${NC}"
    else
        echo -e "${RED}      ✗ 依赖安装失败${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}      ! 未找到 requirements.txt，跳过依赖检查${NC}"
fi

# 检查数据文件
echo -e "${YELLOW}[4/4] 检查数据文件...${NC}"
DATA_FILE="$SCRIPT_DIR/customerchurn.csv"
if [ -f "$DATA_FILE" ]; then
    echo -e "${GREEN}      ✓ 找到 customerchurn.csv${NC}"
else
    echo -e "${YELLOW}      ! 未找到 customerchurn.csv，模型将在启动时尝试查找${NC}"
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  启动应用...${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 打开浏览器的函数
open_browser() {
    sleep 2
    if command -v open &> /dev/null; then
        # macOS
        open "http://localhost:5001/"
    elif command -v xdg-open &> /dev/null; then
        # Linux
        xdg-open "http://localhost:5001/"
    else
        echo -e "${YELLOW}      ! 无法自动打开浏览器，请手动访问 http://localhost:5001/${NC}"
    fi
}

# 在后台打开浏览器
open_browser &

echo -e "${GREEN}  应用将在 http://localhost:5001/ 运行${NC}"
echo -e "${YELLOW}  正在打开浏览器...${NC}"
echo -e "${RED}  按 Ctrl+C 停止服务${NC}"
echo ""

# 启动 Flask 应用
$PYTHON_CMD app.py
