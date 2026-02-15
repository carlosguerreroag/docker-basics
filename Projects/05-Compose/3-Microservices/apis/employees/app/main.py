from fastapi import FastAPI
from .database import get_connection

app = FastAPI()

@app.on_event("startup")
def startup():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS employees (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100)
        );
    """)
    conn.commit()
    cur.close()
    conn.close()

@app.post("/employees")
def create_employee(employee: dict):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO employees (name) VALUES (%s) RETURNING id;",
        (employee["name"],)
    )
    new_id = cur.fetchone()["id"]
    conn.commit()
    cur.close()
    conn.close()
    return {"id": new_id, "name": employee["name"]}

@app.get("/employees")
def get_employees():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM employees;")
    employees = cur.fetchall()
    cur.close()
    conn.close()
    return employees
