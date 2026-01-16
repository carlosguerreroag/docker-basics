FROM python:3.12-slim

WORKDIR /api

COPY requirements.txt .

RUN pip3 install --no-cache-dir -r  requirements.txt

COPY api.py .

CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "3000"]
