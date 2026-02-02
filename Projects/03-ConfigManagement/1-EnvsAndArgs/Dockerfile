FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# ARG (build-time) -> ENV (runtime)
# Default api port comes from an arg
ARG APP_PORT=0
ENV APP_PORT=${APP_PORT}

# Default api env is staging
ARG APP_ENV=staging
ENV APP_ENV=${APP_ENV}

# Extra envs
ENV VAR1="Hi from Dockerfile!"

CMD uvicorn app:app --host 0.0.0.0 --port ${APP_PORT}
