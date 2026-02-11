import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello():
    # El secreto inyectado por Terraform desde Key Vault
    secret_val = os.getenv('MY_SECRET', 'No se encontró el secreto')
    return jsonify({
        "message": "Hola Mundo desde TechFlow!",
        "secret_value": secret_val,
        "status": "success"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)