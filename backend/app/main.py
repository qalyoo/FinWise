from fastapi import FastAPI
from app.database import engine, Base
from app.models.models import User, Category, Transaction
from app.routers import users, transactions
from app.routers import categories
from app.routers import analytics

Base.metadata.create_all(bind=engine)

app = FastAPI(title="FinWise API")

app.include_router(users.router)
app.include_router(transactions.router)

@app.get("/")
def root():
    return {"message": "FinWise API is running"}

Base.metadata.create_all(bind=engine)
app = FastAPI(title='FinWise API')

app.include_router(users.router)
app.include_router(transactions.router)
app.include_router(categories.router)
app.include_router(analytics.router)
@app.get('/')
def root():
    return {'message': 'Welcome to FinWise API'}