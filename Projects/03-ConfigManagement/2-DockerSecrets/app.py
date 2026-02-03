import os
import yaml
from fastapi import FastAPI, Header, HTTPException, status, Depends

def read_token(path: str, required: bool = True):
    try:
        with open(path) as f:
            return f.read().strip()
    except FileNotFoundError:
        if required:
            raise RuntimeError(f"token file not found: {path}")
        return None

def verify_token(token: str = Header(..., alias="Token")):
    if token != APP_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token not valid"
        )

APP_token = read_token("/run/secrets/app_token")

app = FastAPI()
@app.get("/", dependencies=[Depends(verify_token)])
def root():
    return {
        "message": "Hello there!"}
