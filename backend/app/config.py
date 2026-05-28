from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    mongo_url: str = "mongodb://localhost:27017"
    database_name: str = "bloomly"
    secret_key: str = "changeme"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 10080  # 7 days

    google_client_id: str = ""

    ai_service_url: str = ""
    ai_api_key: str = ""

    class Config:
        env_file = ".env"


settings = Settings()
