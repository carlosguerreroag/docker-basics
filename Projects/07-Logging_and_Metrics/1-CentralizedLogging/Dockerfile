FROM python:3.11-slim

RUN apt update -y && apt install curl -y

WORKDIR /app

COPY app.py .

CMD ["python", "app.py"]
