from fastapi import FastAPI
from contextlib import asynccontextmanager
from .routes import health
from fastapi.middleware.cors import CORSMiddleware


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 Application starting up...")
    yield
    print("🛠️ Application shutting down...")


app = FastAPI(lifespan=lifespan)
origins = ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"message": "Docker!"}


app.include_router(health.router)