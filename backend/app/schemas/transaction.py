from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.models.models import TransactionType

class TransactionCreate(BaseModel):
    amount: float
    type: TransactionType
    category_id: Optional[int] = None
    description: Optional[str] = None

class TransactionUpdate(BaseModel):
    amount: Optional[float] = None
    type: Optional[TransactionType] = None
    category_id: Optional[int] = None
    description: Optional[str] = None


class TransactionResponse(BaseModel):
    id: int
    amount: float
    type: TransactionType
    category_id: Optional[int]
    description: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True