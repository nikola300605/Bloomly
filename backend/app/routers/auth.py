from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, timedelta

from jose import jwt
from passlib.context import CryptContext

from app.config import settings
from app.database import get_database
from app.dependencies import get_current_user_id

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class GoogleAuthRequest(BaseModel):
    id_token: str


class AppleAuthRequest(BaseModel):
    identity_token: str
    full_name: Optional[str] = None


class EmailSignupRequest(BaseModel):
    email: str
    password: str
    name: str
    handle: str


class EmailLoginRequest(BaseModel):
    email: str
    password: str


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str


def create_access_token(user_id: str) -> str:
    expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    return jwt.encode(
        {"sub": user_id, "exp": expire},
        settings.secret_key,
        algorithm=settings.algorithm,
    )


@router.post("/google", response_model=TokenOut)
async def auth_google(req: GoogleAuthRequest):
    """Verify a Google Sign-In id_token and upsert the user."""
    # TODO: verify with google.oauth2.id_token.verify_oauth2_token()
    # from google.oauth2 import id_token
    # from google.auth.transport import requests as grequests
    # idinfo = id_token.verify_oauth2_token(req.id_token, grequests.Request(), settings.google_client_id)
    raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail="Google auth not yet wired up")


@router.post("/apple", response_model=TokenOut)
async def auth_apple(req: AppleAuthRequest):
    """Verify an Apple identity token and upsert the user."""
    # TODO: verify Apple JWT against Apple's public keys
    raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail="Apple auth not yet wired up")


@router.post("/email/signup", response_model=TokenOut, status_code=status.HTTP_201_CREATED)
async def email_signup(req: EmailSignupRequest):
    db = get_database()
    if await db.users.find_one({"email": req.email}):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
    if await db.users.find_one({"handle": req.handle}):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Handle already taken")

    doc = {
        "name": req.name,
        "handle": req.handle,
        "email": req.email,
        "password_hash": pwd_context.hash(req.password),
        "created_at": datetime.utcnow(),
    }
    result = await db.users.insert_one(doc)
    user_id = str(result.inserted_id)
    return TokenOut(access_token=create_access_token(user_id), user_id=user_id)


@router.post("/refresh", response_model=TokenOut)
async def refresh_token(user_id: str = Depends(get_current_user_id)):
    """Re-issue an access token for a still-valid session (sliding session).

    The client calls this proactively shortly before the current token expires.
    Requires a currently-valid bearer token; an expired token is rejected with
    401, which signals the client to send the user back to login.
    """
    return TokenOut(access_token=create_access_token(user_id), user_id=user_id)


@router.post("/email/login", response_model=TokenOut)
async def email_login(req: EmailLoginRequest):
    db = get_database()
    user = await db.users.find_one({"email": req.email})
    if not user or not pwd_context.verify(req.password, user.get("password_hash", "")):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    user_id = str(user["_id"])
    return TokenOut(access_token=create_access_token(user_id), user_id=user_id)
