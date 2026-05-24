from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.models import ScheduledPayment, User
from app.schemas.scheduled_payment import ScheduledPaymentCreate, ScheduledPaymentUpdate, ScheduledPaymentResponse
from app.routers.transactions import get_current_user

router = APIRouter(prefix="/scheduled-payments", tags=["scheduled-payments"])

@router.post("/", response_model=ScheduledPaymentResponse)
def create_scheduled_payment(
    data: ScheduledPaymentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    payment = ScheduledPayment(
        user_id=current_user.id,
        name=data.name,
        amount=data.amount,
        day_of_month=data.day_of_month,
        category=data.category,
        is_active=data.is_active,
    )
    db.add(payment)
    db.commit()
    db.refresh(payment)
    return payment

@router.get("/", response_model=List[ScheduledPaymentResponse])
def get_scheduled_payments(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return db.query(ScheduledPayment).filter(
        ScheduledPayment.user_id == current_user.id
    ).all()

@router.put("/{payment_id}", response_model=ScheduledPaymentResponse)
def update_scheduled_payment(
    payment_id: int,
    data: ScheduledPaymentUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    payment = db.query(ScheduledPayment).filter(
        ScheduledPayment.id == payment_id,
        ScheduledPayment.user_id == current_user.id
    ).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Платіж не знайдено")

    if data.name is not None:
        payment.name = data.name
    if data.amount is not None:
        payment.amount = data.amount
    if data.day_of_month is not None:
        payment.day_of_month = data.day_of_month
    if data.category is not None:
        payment.category = data.category
    if data.is_active is not None:
        payment.is_active = data.is_active

    db.commit()
    db.refresh(payment)
    return payment

@router.delete("/{payment_id}")
def delete_scheduled_payment(
    payment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    payment = db.query(ScheduledPayment).filter(
        ScheduledPayment.id == payment_id,
        ScheduledPayment.user_id == current_user.id
    ).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Платіж не знайдено")
    db.delete(payment)
    db.commit()
    return {"message": "Платіж видалено"}

@router.patch("/{payment_id}/toggle")
def toggle_scheduled_payment(
    payment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    payment = db.query(ScheduledPayment).filter(
        ScheduledPayment.id == payment_id,
        ScheduledPayment.user_id == current_user.id
    ).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Платіж не знайдено")
    payment.is_active = 0 if payment.is_active == 1 else 1
    db.commit()
    db.refresh(payment)
    return {"is_active": payment.is_active}