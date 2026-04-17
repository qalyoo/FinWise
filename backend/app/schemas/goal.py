from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime

class GoalCreate(BaseModel):
    title: str
    target_amount: float
    deadline: Optional[datetime] = None

    @validator('target_amount')
    def target_amount_validator(cls, v):
        if v < 0:
            raise ValueError('Сума цілі має бути більше нуля')
        return v

class GoalDeposit(BaseModel):
    amount: float

    @validator('amount')
    def validate_amount(cls, v):
        if v <= 0:
            raise ValueError('Сума поповнення має бути більше нуля')
        return v

class GoalResponse(BaseModel):
    id: int
    title: str
    target_amount: float
    current_amount: float
    deadline: Optional[datetime]
    created_at: datetime
    percent_completed: float
    is_completed: bool

    class Config:
        from_attributes = True