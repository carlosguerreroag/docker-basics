import os
import yaml
from fastapi import FastAPI

def get_env_var(name: str, required: bool = False, default=None):
    value = os.environ.get(name, default)
    if required and value is None:
        raise RuntimeError(f"Mandatory env not defined {name}")
    return value

with open("/config/config.yaml") as file:
    config = yaml.safe_load(file)

APP_ENV = config["env"]
MSG = get_env_var("MSG", default="Hello from app code")
VAR1 = get_env_var("VAR1")
VAR2 = get_env_var("VAR2", required=True)
VAR3 = get_env_var("VAR3")

app = FastAPI()

@app.get("/")
def root():
    return {
        "env": APP_ENV,
        "msg": MSG,
        "var1": VAR1,
        "var2": VAR2,
        "var3": VAR3
    }


