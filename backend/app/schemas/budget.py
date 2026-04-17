from pydantic import BaseModel, validator
from typing import Optional
import re

class BudgetCreate(BaseModel):
    category_id: int
    limit_amount: float
    month: str

    @validator('month')
    def validate_month_format(cls, v):
        if not re.match(r'^\d{4}-\d{2}$', v):
            raise ValueError('Місяць має бути у форматі YYYY-MM, наприклад: 2026-04')
        return v

class BudgetResponse(BaseModel):
    id: int
    category_id: int
    limit_amount: float
    month: str

    class Config:
        from_attributes = True

class BudgetStatus(BaseModel):
    category_name: str
    limit_amount: float
    spent_amount: float
    remaining: float
    percent_used: float
    is_exceeded: bool