from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"msg": "Hi from the main page"}

@app.get("/health")
def health():
    return {"status": "ok"}
