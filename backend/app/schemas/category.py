from pydantic import BaseModel
from app.models.models import TransactionType

class CategoryCreate(BaseModel):
    name: str
    type: TransactionType

class CategoryResponse(BaseModel):
    id: int
    name:str
    type: TransactionType

    class Config:
        from_attributes = True