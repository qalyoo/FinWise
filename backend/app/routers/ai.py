import os
import requests as http_requests
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app.models.models import Transaction, User, TransactionType
from app.routers.transactions import get_current_user
from dotenv import load_dotenv
import json

load_dotenv()

router = APIRouter(prefix="/ai", tags=["ai"])

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

class AIRequest(BaseModel):
    question: str

class AIResponse(BaseModel):
    answer: str

@router.post("/advice", response_model=AIResponse)
def get_advice(
    request: AIRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    transactions = db.query(Transaction).filter(
        Transaction.user_id == current_user.id
    ).order_by(Transaction.created_at.desc()).limit(50).all()

    if not transactions:
        raise HTTPException(status_code=400, detail="No transactions found")

    total_income = sum(t.amount for t in transactions if t.type == TransactionType.income)
    total_expense = sum(t.amount for t in transactions if t.type == TransactionType.expense)
    balance = total_income - total_expense

    by_category = {}
    for t in transactions:
        if t.type == TransactionType.expense and t.category_id:
            cat_name = t.category.name if t.category else "Other"
            by_category[cat_name] = by_category.get(cat_name, 0) + t.amount

    category_text = ", ".join([f"{k}: {v} UAH" for k, v in by_category.items()])

    prompt = (
        f"You are FinWise financial assistant. "
        f"Income: {total_income} UAH, Expenses: {total_expense} UAH, Balance: {balance} UAH. "
        f"Categories: {category_text}. "
        f"Question: {request.question}. "
        f"Answer in 3-5 sentences in English."
    )

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key={GEMINI_API_KEY}"

    payload = {
        "contents": [{"parts": [{"text": prompt}]}]
    }

    try:
        resp = http_requests.post(url, json=payload, timeout=30)
        data = resp.json()
        print("API Response:", data)  # виведе в термінал
        answer = data["candidates"][0]["content"]["parts"][0]["text"]
        return AIResponse(answer=answer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI Error: {str(e)}")