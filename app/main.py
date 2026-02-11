import os
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    my_secret = os.getenv("MY_SECRET", "Secret not found")
    return {
        "message": "Hola Mundo TechFlow",
        "MY_SECRET": my_secret
    }