from fastapi import FastAPI
from .database import get_connection

app = FastAPI()

@app.on_event("startup")
def startup():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100)
        );
    """)
    conn.commit()
    cur.close()
    conn.close()

@app.post("/users")
def create_user(user: dict):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO users (name) VALUES (%s) RETURNING id;",
        (user["name"],)
    )
    new_id = cur.fetchone()["id"]
    conn.commit()
    cur.close()
    conn.close()
    return {"id": new_id, "name": user["name"]}

@app.get("/users")
def get_users():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM users;")
    users = cur.fetchall()
    cur.close()
    conn.close()
    return users
