from pydantic import BaseModel
from typing import Dict, List

class MonthlyStat(BaseModel):
    month: str
    income: float
    expense: float
    balance: float

class SummaryResponse(BaseModel):
    total_income: float
    total_expense: float
    balance: float
    by_category: Dict[str, float]

class MonthlyResponse(BaseModel):
    stats: List[MonthlyStat]
