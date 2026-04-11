from flask import Flask, render_template, request, jsonify, send_file
import pandas as pd
import numpy as np
import os
import io
from datetime import datetime

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

# Model coefficients
COEFFICIENTS = {
    'const': -0.693422,
    'MonthlyCharges': 0.004137,
    'SeniorCitizen': 0.344834,
    'tenure': -0.032446,
    'PaymentMethod_Credit card': -0.068783,
    'PaymentMethod_Electronic check': 0.426260,
    'PaymentMethod_Mailed check': -0.059097,
    'InternetService_Fiber optic': 0.905137,
    'InternetService_No': -0.776021,
    'Contract_One year': -0.765261,
    'Contract_Two year': -1.535946
}

RISK_THRESHOLDS = {'High': 0.7, 'Medium': 0.4, 'Low': 0.0}

def get_risk_level(probability):
    if probability >= RISK_THRESHOLDS['High']:
        return 'High'
    elif probability >= RISK_THRESHOLDS['Medium']:
        return 'Medium'
    else:
        return 'Low'

def get_recommendations(risk_level):
    recommendations = {
        'High': [
            "立即联系客户，了解不满原因",
            "提供专属优惠或折扣方案",
            "考虑升级服务或提供增值服务",
            "安排客户经理进行一对一沟通",
            "提供合同升级优惠（如月付转年付）"
        ],
        'Medium': [
            "发送客户满意度调查",
            "提供针对性的产品推荐",
            "定期跟进客户使用情况",
            "提供自助服务优化建议",
            "考虑提供小幅优惠以提升忠诚度"
        ],
        'Low': [
            "保持常规客户关系维护",
            "定期发送产品更新信息",
            "邀请参与推荐计划",
            "提供增值服务介绍",
            "保持良好的服务质量"
        ]
    }
    return recommendations.get(risk_level, [])

def predict_churn(data):
    if isinstance(data, dict):
        data = pd.DataFrame([data])
    
    logit = COEFFICIENTS['const']
    logit += COEFFICIENTS['MonthlyCharges'] * data['MonthlyCharges']
    logit += COEFFICIENTS['SeniorCitizen'] * data['SeniorCitizen']
    logit += COEFFICIENTS['tenure'] * data['tenure']
    
    logit += COEFFICIENTS['PaymentMethod_Credit card'] * (data['PaymentMethod'] == 'Credit card').astype(int)
    logit += COEFFICIENTS['PaymentMethod_Electronic check'] * (data['PaymentMethod'] == 'Electronic check').astype(int)
    logit += COEFFICIENTS['PaymentMethod_Mailed check'] * (data['PaymentMethod'] == 'Mailed check').astype(int)
    
    logit += COEFFICIENTS['InternetService_Fiber optic'] * (data['InternetService'] == 'Fiber optic').astype(int)
    logit += COEFFICIENTS['InternetService_No'] * (data['InternetService'] == 'No').astype(int)
    
    logit += COEFFICIENTS['Contract_One year'] * (data['Contract'] == 'One year').astype(int)
    logit += COEFFICIENTS['Contract_Two year'] * (data['Contract'] == 'Two year').astype(int)
    
    probability = 1 / (1 + np.exp(-logit))
    return probability

def process_batch_data(df):
    required_columns = ['MonthlyCharges', 'SeniorCitizen', 'tenure', 'PaymentMethod', 'InternetService', 'Contract']
    missing_columns = [col for col in required_columns if col not in df.columns]
    
    if missing_columns:
        raise ValueError(f"Missing required columns: {', '.join(missing_columns)}")
    
    valid_payment_methods = ['Electronic check', 'Mailed check', 'Bank transfer', 'Credit card']
    valid_internet_services = ['DSL', 'Fiber optic', 'No']
    valid_contracts = ['Month-to-month', 'One year', 'Two year']
    
    invalid_payments = df[~df['PaymentMethod'].isin(valid_payment_methods)]['PaymentMethod'].unique()
    if len(invalid_payments) > 0:
        raise ValueError(f"Invalid PaymentMethod values: {', '.join(invalid_payments)}")
    
    invalid_internet = df[~df['InternetService'].isin(valid_internet_services)]['InternetService'].unique()
    if len(invalid_internet) > 0:
        raise ValueError(f"Invalid InternetService values: {', '.join(invalid_internet)}")
    
    invalid_contracts = df[~df['Contract'].isin(valid_contracts)]['Contract'].unique()
    if len(invalid_contracts) > 0:
        raise ValueError(f"Invalid Contract values: {', '.join(invalid_contracts)}")
    
    probabilities = predict_churn(df)
    df['ChurnProbability'] = probabilities
    df['RiskLevel'] = df['ChurnProbability'].apply(get_risk_level)
    
    return df

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = {
            'MonthlyCharges': float(request.form['monthly_charges']),
            'SeniorCitizen': int(request.form['senior_citizen']),
            'tenure': int(request.form['tenure']),
            'PaymentMethod': request.form['payment_method'],
            'InternetService': request.form['internet_service'],
            'Contract': request.form['contract']
        }
        
        if data['MonthlyCharges'] < 0:
            return jsonify({'error': 'MonthlyCharges must be non-negative'}), 400
        if data['tenure'] < 0:
            return jsonify({'error': 'tenure must be non-negative'}), 400
        if data['SeniorCitizen'] not in [0, 1]:
            return jsonify({'error': 'SeniorCitizen must be 0 or 1'}), 400
        
        probability = predict_churn(data)[0]
        risk_level = get_risk_level(probability)
        recommendations = get_recommendations(risk_level)
        
        return jsonify({
            'success': True,
            'probability': round(probability * 100, 2),
            'risk_level': risk_level,
            'recommendations': recommendations
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/batch_predict', methods=['POST'])
def batch_predict():
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        filename = file.filename.lower()
        if filename.endswith('.csv'):
            df = pd.read_csv(file)
        elif filename.endswith(('.xlsx', '.xls')):
            df = pd.read_excel(file)
        else:
            return jsonify({'error': 'Unsupported file format. Please upload CSV or Excel file.'}), 400
        
        result_df = process_batch_data(df)
        
        results = []
        for _, row in result_df.iterrows():
            results.append({
                'row': int(row.name) + 1,
                'monthly_charges': float(row['MonthlyCharges']),
                'senior_citizen': int(row['SeniorCitizen']),
                'tenure': int(row['tenure']),
                'payment_method': str(row['PaymentMethod']),
                'internet_service': str(row['InternetService']),
                'contract': str(row['Contract']),
                'probability': round(float(row['ChurnProbability']) * 100, 2),
                'risk_level': str(row['RiskLevel'])
            })
        
        app.config['LAST_BATCH_RESULTS'] = result_df
        
        return jsonify({
            'success': True,
            'count': len(results),
            'results': results
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/export', methods=['POST'])
def export_results():
    try:
        if 'LAST_BATCH_RESULTS' not in app.config or app.config['LAST_BATCH_RESULTS'] is None:
            return jsonify({'error': 'No results to export. Please run batch prediction first.'}), 400
        
        df = app.config['LAST_BATCH_RESULTS'].copy()
        
        df['Recommendations'] = df['RiskLevel'].apply(
            lambda x: '; '.join(get_recommendations(x))
        )
        
        df['ChurnProbability'] = df['ChurnProbability'].apply(lambda x: f"{x*100:.2f}%")
        
        output = io.BytesIO()
        with pd.ExcelWriter(output, engine='openpyxl') as writer:
            df.to_excel(writer, sheet_name='Churn Predictions', index=False)
        output.seek(0)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'churn_predictions_{timestamp}.xlsx'
        
        return send_file(
            output,
            mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            as_attachment=True,
            download_name=filename
        )
        
    except Exception as e:
        return jsonify({'error': str(e)}), 400

# For Vercel serverless
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5001))
    app.run(debug=True, host='0.0.0.0', port=port)
