from flask import Flask
import psycopg2 # Lib to connect w Postgres
import os

app = Flask(__name__)

def get_password():
    password_file = os.environ.get("POSTGRES_PASSWORD_FILE")
    
    if password_file:
        with open(password_file, 'r') as f:
            return f.read().strip()
    return os.environ.get("POSTGRES_PASSWORD")

# DB Connection function
def db_conn():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        database=os.environ["POSTGRES_DB"],
        user=os.environ["POSTGRES_USER"],
        password=get_password() 
    )

@app.route("/")
def index():
    try:
        conn = db_conn() # Connects with the db
        cur = conn.cursor() # Creates a cursor to start executing sql commands 
        cur.execute("SELECT 1;") # Executes a simple command to check if the db responds
        cur.close() # Closes the cursor (cleanup)
        conn.close() # Closes the connection
        return "API successfully connected to the DB!"
    except Exception as e:
        return f"Connection error: {str(e)}", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
