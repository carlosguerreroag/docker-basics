import os
import json
import pika
import psycopg2
import subprocess

UPLOAD_DIR = "uploads"

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

def transcode(input_path, output_path, resolution):
    subprocess.run([
        "ffmpeg",
        "-i", input_path,
        "-vf", f"scale=-2:{resolution}",
        "-c:v", "libx264",
        "-preset", "fast",
        "-crf", "23",
        "-c:a", "aac",
        "-y",
        output_path
    ], check=True)


def process_video(ch, method, properties, body):
    data = json.loads(body)
    video_id = data["video_id"]
    input_path = data["path"]

    print(f"Processing video {video_id}")

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("UPDATE videos SET status=%s WHERE id=%s",
                ("processing", video_id))
    conn.commit()

    base_name = os.path.splitext(input_path)[0]

    try:
        # 128p
        transcode(input_path, f"{base_name}_128p.mp4", 128)

        # 360p
        transcode(input_path, f"{base_name}_360p.mp4", 360)

        cur.execute("UPDATE videos SET status=%s WHERE id=%s",
                    ("done", video_id))
        conn.commit()

    except Exception as e:
        print("Error:", e)
        cur.execute("UPDATE videos SET status=%s WHERE id=%s",
                    ("error", video_id))
        conn.commit()

    cur.close()
    conn.close()

    ch.basic_ack(delivery_tag=method.delivery_tag)


connection = pika.BlockingConnection(
    pika.ConnectionParameters(host=RABBITMQ_HOST)
)

channel = connection.channel()
channel.queue_declare(queue="video_tasks", durable=True)
channel.basic_qos(prefetch_count=1)

channel.basic_consume(queue="video_tasks", on_message_callback=process_video)

print("Worker waiting for videos...")
channel.start_consuming()

