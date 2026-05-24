from pydantic import BaseModel, validator
from typing import Optional

class ScheduledPaymentCreate(BaseModel):
    name: str
    amount: float
    day_of_month: int
    category: Optional[str] = None
    is_active: Optional[int] = 1

    @validator('amount')
    def validate_amount(cls, v):
        if v <= 0:
            raise ValueError('Сума має бути більше нуля')
        return v

    @validator('day_of_month')
    def validate_day(cls, v):
        if v < 1 or v > 31:
            raise ValueError('День місяця має бути від 1 до 31')
        return v

class ScheduledPaymentUpdate(BaseModel):
    name: Optional[str] = None
    amount: Optional[float] = None
    day_of_month: Optional[int] = None
    category: Optional[str] = None
    is_active: Optional[int] = None

class ScheduledPaymentResponse(BaseModel):
    id: int
    name: str
    amount: float
    day_of_month: int
    category: Optional[str]
    is_active: int

    class Config:
        from_attributes = True