from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import connect_db, close_db
from app.routers import auth, plants, scan, articles, users, catalog


@asynccontextmanager
async def lifespan(app: FastAPI):
    await connect_db()
    yield
    await close_db()


app = FastAPI(
    title="Bloomly API",
    version="0.1.0",
    description="Backend for the Bloomly gardening helper app",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(plants.router, prefix="/plants", tags=["plants"])
app.include_router(scan.router, prefix="/scan", tags=["scan"])
app.include_router(articles.router, prefix="/articles", tags=["articles"])
app.include_router(users.router, prefix="/users", tags=["users"])
app.include_router(catalog.router, prefix="/catalog", tags=["catalog"])


@app.get("/health", tags=["meta"])
async def health():
    return {"status": "ok"}
