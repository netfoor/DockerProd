from fastapi import APIRouter, status
from .. import schemas

router = APIRouter(
    prefix="/health",
    tags=["Health"]
)

@router.get("/", status_code=status.HTTP_200_OK, response_model=schemas.HealthResponse)
def health_check():
    return schemas.HealthResponse(status="OK")
