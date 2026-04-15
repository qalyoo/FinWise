from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.database import get_db
from app.models.models import Transaction, Category, User, TransactionType
from app.routers.transactions import get_current_user

router = APIRouter(prefix="/analytics", tags=["analytics"])

@router.get("/summary")
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

    return {
        "total_income": total_income,
        "total_expense": total_expense,
        "balance": balance,
        "by_category": by_category
    }