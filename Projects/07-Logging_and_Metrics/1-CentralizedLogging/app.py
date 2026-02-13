import logging
import json
import sys
import time
from datetime import datetime

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "service": "python-app",
            "message": record.getMessage(),
        }
        return json.dumps(log_record)

logger = logging.getLogger()
logger.setLevel(logging.INFO)

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())
logger.addHandler(handler)

while True:
    logger.info("Application running")
    time.sleep(5)
