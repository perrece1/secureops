from fastapi import FastAPI
import os

app = FastAPI(title="SecureOps Demo API", version="1.0.0")

@app.get("/")
def read_root():
    return {
        "status": "online",
        "message": "SecureOps K8s Cluster Provisioner API",
        "environment": os.getenv("ENV", "development")
    }

@app.get("/health")
def health_check():
    return {"status": "healthy"}
