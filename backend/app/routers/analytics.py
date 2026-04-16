from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
from collections import defaultdict
from app.database import get_db
from app.models.models import Transaction, User, TransactionType
from app.schemas.analytics import SummaryResponse, MonthlyResponse, MonthlyStat
from app.routers.transactions import get_current_user

router = APIRouter(prefix="/analytics", tags=["analytics"])

@router.get("/summary", response_model=SummaryResponse)
def get_summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    transactions = db.query(Transaction).filter(Transaction.user_id == current_user.id).all()

    total_income = sum(t.amount for t in transactions if t.type == TransactionType.income)
    total_expense = sum(t.amount for t in transactions if t.type == TransactionType.expense)
    balance = total_income - total_expense

    by_category = {}
    for t in transactions:
        if t.type == TransactionType.expense and t.category_id:
            cat_name = t.category.name if t.category else "Без категорії"
            by_category[cat_name] = by_category.get(cat_name, 0) + t.amount

    return SummaryResponse(
        total_income=total_income,
        total_expense=total_expense,
        balance=balance,
        by_category=by_category
    )

@router.get("/monthly", response_model=MonthlyResponse)
def get_monthly(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    transactions = db.query(Transaction).filter(
        Transaction.user_id == current_user.id
    ).order_by(Transaction.created_at).all()

    monthly = defaultdict(lambda: {"income": 0.0, "expense": 0.0})

    for t in transactions:
        month_key = t.created_at.strftime("%Y-%m")
        if t.type == TransactionType.income:
            monthly[month_key]["income"] += t.amount
        else:
            monthly[month_key]["expense"] += t.amount

    stats = [
        MonthlyStat(
            month=month,
            income=data["income"],
            expense=data["expense"],
            balance=data["income"] - data["expense"]
        )
        for month, data in sorted(monthly.items())
    ]

    return MonthlyResponse(stats=stats)