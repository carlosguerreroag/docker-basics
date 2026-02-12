import os
import json
import uuid
import pika
import psycopg2
from fastapi import FastAPI, UploadFile, File

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

app = FastAPI()

RABBITMQ_HOST = os.getenv("RABBITMQ_HOST")
DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_NAME = os.getenv("DB_NAME")

def get_password():
    password_file = os.environ.get("POSTGRES_PASSWORD_FILE")

    if password_file:
        with open(password_file, 'r') as f:
            return f.read().strip()
    return os.environ.get("DB_PASSWORD")

def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=get_password(),
        dbname=DB_NAME
    )

def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS videos (
            id UUID PRIMARY KEY,
            status TEXT,
            original_path TEXT
        );
    """)
    conn.commit()
    cur.close()
    conn.close()


@app.on_event("startup")
def startup():
    init_db()


@app.post("/videos")
async def upload_video(file: UploadFile = File(...)):
    video_id = str(uuid.uuid4())
    file_path = f"{UPLOAD_DIR}/{video_id}_{file.filename}"

    with open(file_path, "wb") as f:
        f.write(await file.read())

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO videos (id, status, original_path) VALUES (%s, %s, %s)",
        (video_id, "pending", file_path)
    )
    conn.commit()
    cur.close()
    conn.close()

    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=RABBITMQ_HOST)
    )
    channel = connection.channel()
    channel.queue_declare(queue="video_tasks", durable=True)

    channel.basic_publish(
        exchange="",
        routing_key="video_tasks",
        body=json.dumps({"video_id": video_id, "path": file_path}),
        properties=pika.BasicProperties(delivery_mode=2),
    )

    connection.close()

    return {"video_id": video_id, "status": "pending"}

@app.get("/videos/{video_id}")
def get_video_status(video_id: str):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT status FROM videos WHERE id = %s", (video_id,))
    row = cur.fetchone()
    cur.close()
    conn.close()

    if not row:
        # No se encontró el video
        raise HTTPException(status_code=404, detail="Video not found")

    status = row[0]
    return {"video_id": video_id, "status": status}
