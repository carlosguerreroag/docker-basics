FROM python:3.11-slim

RUN apt update -y && apt install curl -y

WORKDIR /api

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY api.py .

CMD ["python", "api.py"]
