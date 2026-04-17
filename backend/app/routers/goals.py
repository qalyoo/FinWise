from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.models import Goal, User
from app.schemas.goal import GoalCreate, GoalDeposit, GoalResponse
from app.routers.transactions import get_current_user

router = APIRouter(prefix="/goals", tags=["goals"])

def build_response(goal: Goal) -> GoalResponse:
    percent = round((goal.current_amount / goal.target_amount) * 100, 1) if goal.target_amount > 0 else 0
    return GoalResponse(
        id=goal.id,
        title=goal.title,
        target_amount=goal.target_amount,
        current_amount=goal.current_amount,
        deadline=goal.deadline,
        created_at=goal.created_at,
        percent_completed=min(percent, 100.0),
        is_completed=goal.current_amount >= goal.target_amount
    )

@router.post("/", response_model=GoalResponse)
def create_goal(
    data: GoalCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    goal = Goal(
        user_id=current_user.id,
        title=data.title,
        target_amount=data.target_amount,
        deadline=data.deadline
    )
    db.add(goal)
    db.commit()
    db.refresh(goal)
    return build_response(goal)

@router.get("/", response_model=List[GoalResponse])
def get_goals(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    goals = db.query(Goal).filter(Goal.user_id == current_user.id).all()
    return [build_response(g) for g in goals]

@router.get("/{goal_id}", response_model=GoalResponse)
def get_goal(
    goal_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    goal = db.query(Goal).filter(
        Goal.id == goal_id,
        Goal.user_id == current_user.id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Ціль не знайдено")
    return build_response(goal)

@router.put("/{goal_id}/deposit", response_model=GoalResponse)
def deposit_goal(
    goal_id: int,
    data: GoalDeposit,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    goal = db.query(Goal).filter(
        Goal.id == goal_id,
        Goal.user_id == current_user.id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Ціль не знайдено")
    if goal.current_amount >= goal.target_amount:
        raise HTTPException(status_code=400, detail="Ціль вже досягнута")

    goal.current_amount += data.amount
    db.commit()
    db.refresh(goal)
    return build_response(goal)

@router.delete("/{goal_id}")
def delete_goal(
    goal_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    goal = db.query(Goal).filter(
        Goal.id == goal_id,
        Goal.user_id == current_user.id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Ціль не знайдено")
    db.delete(goal)
    db.commit()
    return {"message": "Ціль видалено"}