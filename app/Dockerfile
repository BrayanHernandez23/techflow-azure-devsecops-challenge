FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir flask

COPY app.py .

EXPOSE 8000

CMD ["python", "app.py"]