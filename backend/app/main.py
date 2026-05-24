from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine, Base
from app.models.models import User, Category, Transaction
from app.routers import users, transactions
from app.routers import categories
from app.routers import analytics
from app.routers import budgets
from app.routers import goals
from app.routers import ai
from app.routers import scheduled_payments

Base.metadata.create_all(bind=engine)

app = FastAPI(title="FinWise API")

app.include_router(users.router)
app.include_router(transactions.router)

@app.get("/")
def root():
    return {"message": "FinWise API is running"}

Base.metadata.create_all(bind=engine)
app = FastAPI(title='FinWise API')

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users.router)
app.include_router(transactions.router)
app.include_router(categories.router)
app.include_router(analytics.router)
app.include_router(budgets.router)
app.include_router(goals.router)
app.include_router(ai.router)
app.include_router(scheduled_payments.router)
@app.get('/')
def root():
    return {'message': 'Welcome to FinWise API'}