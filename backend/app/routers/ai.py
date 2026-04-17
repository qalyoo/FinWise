from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app.models.models import Transaction, User, TransactionType
from app.routers.transactions import get_current_user
import google.generativeai as genai
import os

router = APIRouter(prefix="/ai", tags=["ai"])

GEMINI_API_KEY = os.getenv("gemini_api_key")
genai.configure(api_key=GEMINI_API_KEY)

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
        raise HTTPException(status_code=400, detail="Немає транзакцій для аналізу")

    total_income = sum(t.amount for t in transactions if t.type == TransactionType.income)
    total_expense = sum(t.amount for t in transactions if t.type == TransactionType.expense)
    balance = total_income - total_expense

    by_category = {}
    for t in transactions:
        if t.type == TransactionType.expense and t.category_id:
            cat_name = t.category.name if t.category else "Без категорії"
            by_category[cat_name] = by_category.get(cat_name, 0) + t.amount

    category_text = "\n".join([f"- {k}: {v} грн" for k, v in by_category.items()])

    prompt = f"""Ти фінансовий асистент додатку FinWise. Відповідай українською мовою.

Фінансові дані користувача:
- Загальний дохід: {total_income} грн
- Загальні витрати: {total_expense} грн
- Баланс: {balance} грн
- Витрати по категоріях:
{category_text}

Питання користувача: {request.question}

Дай коротку, конкретну та корисну відповідь (3-5 речень)."""

    try:
        model = genai.GenerativeModel("gemini-pro")
        response = model.generate_content(prompt)
        return AIResponse(answer=response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Помилка AI: {str(e)}")