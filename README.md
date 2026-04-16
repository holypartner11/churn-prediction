# 客户流失预测系统

这是一个基于逻辑回归的客户流失预测 Web 应用，推理逻辑已经和 notebook 里的训练口径对齐。

## 功能特性

- 单个客户预测：输入客户信息，返回流失概率、风险等级和挽留建议
- 批量预测：支持上传 CSV 或 Excel 文件批量分析
- 双模型切换：支持原模型和重建模型
- 四档风险分层：高风险、较高风险、中等风险、低风险
- 结果导出：批量预测结果可导出为 Excel

## 输入字段

| 字段 | 类型 | 说明 |
|------|------|------|
| MonthlyCharges | float | 月消费金额，仅用于表单输入兼容 |
| SeniorCitizen | 0/1 | 是否老年客户 |
| tenure | int | 在网时长（月） |
| PaymentMethod | 枚举 | Electronic check / Mailed check / Bank transfer / Credit card |
| InternetService | 枚举 | DSL / Fiber optic / No |
| Contract | 枚举 | Month-to-month / One year / Two year |

## 模型说明

应用启动时会根据 [customerchurn.csv](customerchurn.csv) 重新训练两套模型，保证和 [source/tel_logistic_v3.ipynb](source/tel_logistic_v3.ipynb) 的数据处理逻辑一致。

- 原模型：7 个特征
- 重建模型：3 个特征

相关训练与推理逻辑集中在 [model_service.py](model_service.py)。

## 风险等级

风险等级不是固定写死的旧阈值，而是根据 notebook 中的阈值扫描结果动态生成：

- 高风险
- 较高风险
- 中等风险
- 低风险

## 运行方式

### 本地启动

Windows 推荐直接双击 [run-me-windows.bat](run-me-windows.bat)，它会自动绕过 PowerShell 执行策略并启动服务。

Mac 推荐直接双击 [run-me-macos.command](run-me-macos.command)，它会调用 [start-app.sh](start-app.sh) 启动服务。

```bash
cd churn-prediction-main
pip install -r requirements.txt
python app.py
```

应用默认运行在 `http://localhost:5001`。

### Vercel 部署（暂不支持）

Vercel 入口在 [api/index.py](api/index.py)，路由配置在 [vercel.json](vercel.json)。

## 批量文件格式

上传的 CSV 或 Excel 文件至少需要包含以下列：

```csv
MonthlyCharges,SeniorCitizen,tenure,PaymentMethod,InternetService,Contract
65.50,0,12,Electronic check,Fiber optic,Month-to-month
89.99,1,24,Credit card,DSL,One year
```

## 项目结构

```
churn-prediction-main/
├── app.py
├── api/
│   └── index.py
├── model_service.py
├── customerchurn.csv
├── data/
│   └── sample_data.csv
├── source/
│   └── tel_logistic_v3.ipynb
├── templates/
│   └── index.html
├── requirements.txt
├── README.md
├── Procfile
├── run-me-windows.bat
├── run-me-macos.command
├── start-app.ps1
├── start-app.sh
└── vercel.json
```

## 依赖

主要依赖如下：Flask、pandas、NumPy、scikit-learn、openpyxl、gunicorn。

## 说明

`MonthlyCharges` 在当前应用里用于表单和批量文件兼容，但不会直接参与当前 notebook 对齐后的模型推理。
