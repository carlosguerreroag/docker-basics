import os
import psycopg2
from psycopg2.extras import RealDictCursor

def get_password():
    password_file = os.environ.get("POSTGRES_PASSWORD_FILE")

    if password_file and os.path.exists(password_file):
        with open(password_file, "r") as f:
            return f.read().strip()

    return os.environ.get("POSTGRES_PASSWORD")


def get_connection():
    return psycopg2.connect(
        host=os.environ.get("DB_HOST", "postgres"),
        port=os.environ.get("DB_PORT", 5432),
        database=os.environ["POSTGRES_DB"],
        user=os.environ["POSTGRES_USER"],
        password=get_password(),
        cursor_factory=RealDictCursor
    )
