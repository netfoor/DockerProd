FROM python:3.11-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /app

COPY pyproject.toml .
COPY uv.lock .

RUN ~/.local/bin/uv sync --frozen --python=/usr/local/bin/python3

COPY . .


FROM python:3.11-slim AS runtime

RUN useradd -m appuser
USER appuser

WORKDIR /app

COPY --from=builder /app/.venv app/.venv

ENV PATH="/app/.venv/bin:$PATH"

COPY --from=builder /app .

HEALTHCHECK --interval=30s --timeout=5s \
    CMD curl -f http://localhost:8000/health || exit 1

CMD [ "gunicorn", "main:app", "-k", "uvicorn.workers.UvicornWorker", "-b", "0.0.0.0:8000"]
