from flask import Flask
import redis
import os

# REDIS CONNECTION
r = redis.Redis(
  host=os.environ["REDIS_HOST"], 
  port=os.environ["REDIS_PORT"], 
)

# FLASK API
app = Flask(__name__)

@app.route('/')
def index():
    visits = r.incr('visit_count')
    return f"This site has been visited {visits} times!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
