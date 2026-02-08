# PYTHON3 SLIM BASE IMG
FROM python:3.11-slim

# SET /api AS THE WORKDIR
WORKDIR /api

# INSTALL PY DEPS VIA PIP
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# COPY API FILE into WORKDIR
COPY api.py .

# RUN API
CMD ["python3", "api.py"]
