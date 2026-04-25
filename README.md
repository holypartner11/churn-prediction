# 客户流失预测系统

这是一个基于逻辑回归的客户流失预测 Web 应用，推理逻辑已经和 notebook 里的训练口径对齐。

## 在线访问

纯前端版本已通过 GitHub Pages 部署：

🔗 **https://holypartner11.github.io/churn-prediction**

## 🧑‍💻 小组成员

| 姓名           | 学号     |
| ------------- | -------- |
| 马琳琳         | 25210209 |
| 杨金梅         | 25210277 |
| 胡雁雄         | 25210143 |
| 冯一帆         | 25210130 |
| 刘嘉亮         | 25210193 |
| 张橦菲         | 25210296 |
| 蔡柏林         | 25210110 |
| 刘桃蹊（组长）  | 25210195 |

## 功能特性

- 单个客户预测：输入客户信息，返回流失概率、风险等级和挽留建议
- 批量预测：支持上传 CSV 或 Excel 文件批量分析
- 双模型切换：支持原模型（7 特征）和重建模型（3 特征）
- 四档风险分层：高风险、较高风险、中等风险、低风险
- 结果导出：批量预测结果可导出为 Excel

## 输入字段

| 字段 | 类型 | 说明 |
|------|------|------|
| SeniorCitizen | 0/1 | 是否老年客户 |
| tenure | int | 在网时长（月） |
| PaymentMethod | 枚举 | Electronic check / Mailed check / Bank transfer / Credit card |
| InternetService | 枚举 | DSL / Fiber optic / No |
| Contract | 枚举 | Month-to-month / One year / Two year |

> `MonthlyCharges` 在表单和批量文件中保留字段兼容，但不参与模型推理。

## 模型说明

- **原模型**：7 个特征（SeniorCitizen + tenure + InternetService_enc + Contract_enc + PaymentMethod 3 哑变量）
- **重建模型**：3 个特征（tenure + InternetService_enc + Is_Electronic_check）

相关训练与推理逻辑集中在 [model_service.py](model_service.py) 和 [source/tel_logistic_v3.ipynb](source/tel_logistic_v3.ipynb)。

## 运行方式

### 方式一：纯前端 HTML（推荐，无需后端）

项目已提取模型系数，实现为纯前端版本。直接用浏览器打开即可使用，无需安装 Python 依赖。

```bash
# 直接双击打开
open index.html
```

或在终端打开：

```bash
cd churn-prediction-main
open index.html
```

### 方式二：Flask 后端（完整版）

需要 Python 3.x 环境，启动时会根据 `customerchurn.csv` 重新训练模型。

```bash
cd churn-prediction-main
pip install -r requirements.txt
python app.py
```

应用运行在 `http://localhost:5001`。

Windows 推荐双击 [run-me-windows.bat](run-me-windows.bat)。
Mac 推荐双击 [run-me-macos.command](run-me-macos.command) 或运行 [start-app.sh](start-app.sh)。


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
├── index.html              ← 纯前端版本（直接浏览器打开）
├── model_params.json       ← 前端模型系数配置
├── app.py                  ← Flask 后端入口
├── model_service.py        ← 模型训练与推理服务
├── api/
│   └── index.py            ← Vercel 无服务器入口
├── customerchurn.csv       ← 训练数据集
├── data/
│   └── sample_data.csv
├── source/
│   └── tel_logistic_v3.ipynb
├── templates/
│   └── index.html          ← Flask 前端模板
├── requirements.txt
├── vercel.json
├── README.md
└── ...
```

## 依赖

| 版本 | 依赖 |
|------|------|
| 前端 | SheetJS（CDN 加载） |
| 后端 | Flask, pandas, NumPy, scikit-learn, openpyxl, gunicorn |

## 说明

- 前端版本 `index.html` 中的模型系数从 `model_service.py` 训练结果提取，通过 `extract_params.py` 脚本生成 `model_params.json`。
- 前端预测逻辑使用 JavaScript 实现了与后端完全一致的特征编码 → StandardScaler → Sigmoid 流程，已通过一致性测试（6 组测试用例前后端输出完全一致）。
- 如需更新模型，重新训练后运行提取脚本，更新 `model_params.json` 并刷新 `index.html` 中的参数即可。
