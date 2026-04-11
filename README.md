# 客户流失预测系统

基于逻辑回归模型的客户流失预测 Web 应用。

## 功能特性

- **单个客户预测**: 通过表单输入客户信息，获取流失概率和风险等级
- **批量预测**: 支持上传 CSV 或 Excel 文件进行批量客户分析
- **风险分级**: 自动将客户分为高/中/低三个风险等级
- **策略建议**: 根据风险等级提供相应的客户保留策略
- **结果导出**: 批量预测结果可导出为 Excel 文件

## 模型特征

| 特征 | 类型 | 说明 |
|------|------|------|
| MonthlyCharges | float | 月消费金额 |
| SeniorCitizen | 0/1 | 是否老年客户 |
| tenure | int | 在网时长（月） |
| PaymentMethod | 枚举 | 支付方式：Electronic check, Mailed check, Bank transfer, Credit card |
| InternetService | 枚举 | 互联网服务：DSL, Fiber optic, No |
| Contract | 枚举 | 合同类型：Month-to-month, One year, Two year |

## 风险等级标准

- **高风险 (High)**: 流失概率 ≥ 70%
- **中风险 (Medium)**: 流失概率 40% - 70%
- **低风险 (Low)**: 流失概率 < 40%

## 安装与运行

### 1. 安装依赖

```bash
cd churn_app
pip install -r requirements.txt
```

### 2. 运行应用

```bash
python app.py
```

应用将在 http://localhost:5000 启动

## 批量预测文件格式

上传的 CSV 或 Excel 文件需要包含以下列：

```csv
MonthlyCharges,SeniorCitizen,tenure,PaymentMethod,InternetService,Contract
65.50,0,12,Electronic check,Fiber optic,Month-to-month
89.99,1,24,Credit card,DSL,One year
...
```

## 技术栈

- **后端**: Flask + Python
- **数据处理**: Pandas, NumPy
- **前端**: HTML5 + CSS3 + JavaScript
- **模型**: Logistic Regression (statsmodels)

## 项目结构

```
churn_app/
├── app.py              # Flask 应用主文件
├── requirements.txt    # Python 依赖
├── README.md          # 项目说明
└── templates/
    └── index.html     # 前端页面
```

## 模型系数

```
const: -0.693422
MonthlyCharges: 0.004137
SeniorCitizen: 0.344834
tenure: -0.032446
PaymentMethod_Credit card: -0.068783
PaymentMethod_Electronic check: 0.426260
PaymentMethod_Mailed check: -0.059097
InternetService_Fiber optic: 0.905137
InternetService_No: -0.776021
Contract_One year: -0.765261
Contract_Two year: -1.535946
```
