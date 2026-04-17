from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.models import Budget, Transaction, Category, User, TransactionType
from app.schemas.budget import BudgetCreate, BudgetResponse, BudgetStatus
from app.routers.transactions import get_current_user

router = APIRouter(prefix="/budgets", tags=["budgets"])

@router.post("/", response_model=BudgetResponse)
def create_budget(
    data: BudgetCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    existing = db.query(Budget).filter(
        Budget.user_id == current_user.id,
        Budget.category_id == data.category_id,
        Budget.month == data.month
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Бюджет для цієї категорії вже існує")

    budget = Budget(
        user_id=current_user.id,
        category_id=data.category_id,
        limit_amount=data.limit_amount,
        month=data.month
    )
    db.add(budget)
    db.commit()
    db.refresh(budget)
    return budget

@router.get("/", response_model=List[BudgetResponse])
def get_budgets(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return db.query(Budget).filter(Budget.user_id == current_user.id).all()

@router.get("/status", response_model=List[BudgetStatus])
def get_budget_status(
    month: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    budgets = db.query(Budget).filter(
        Budget.user_id == current_user.id,
        Budget.month == month
    ).all()

    result = []
    for budget in budgets:
        spent = sum(
            t.amount for t in db.query(Transaction).filter(
                Transaction.user_id == current_user.id,
                Transaction.category_id == budget.category_id,
                Transaction.type == TransactionType.expense,
                Transaction.created_at.like(f"{month}%")
            ).all()
        )

        result.append(BudgetStatus(
            category_name=budget.category.name,
            limit_amount=budget.limit_amount,
            spent_amount=spent,
            remaining=budget.limit_amount - spent,
            percent_used=round((spent / budget.limit_amount) * 100, 1) if budget.limit_amount > 0 else 0,
            is_exceeded=spent > budget.limit_amount
        ))

    return result

@router.delete("/{budget_id}")
def delete_budget(
    budget_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    budget = db.query(Budget).filter(
        Budget.id == budget_id,
        Budget.user_id == current_user.id
    ).first()
    if not budget:
        raise HTTPException(status_code=404, detail="Бюджет не знайдено")
    db.delete(budget)
    db.commit()
    return {"message": "Бюджет видалено"}