from fastapi import FastAPI, APIRouter
import yaml
import os

current_directory = os.path.dirname(os.path.abspath(__file__))

config_file = current_directory + "/configs/config.yaml"

with open(config_file, 'r') as file:
    configs = yaml.safe_load(file)

app = FastAPI()
prefix_router = APIRouter(prefix='/sample-api-py')

@prefix_router.get("/")
def read_root():
    return {"message": f"{configs['app']['message']}"}

@prefix_router.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}

@prefix_router.get("/items/")
def create_item(item: dict):
    return {"item": item}

app.include_router(prefix_router)