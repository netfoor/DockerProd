FROM python:3.13-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /app

COPY pyproject.toml uv.lock ./

RUN ~/.local/bin/uv sync --frozen --python=/usr/local/bin/python3

COPY app ./app


FROM python:3.13-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends tini && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash appuser
USER appuser

WORKDIR /app

COPY --from=builder /app/.venv ./.venv
COPY --from=builder /app/app ./app

ENV PATH="/app/.venv/bin:$PATH"

ENTRYPOINT [ "/usr/bin/tini", "--" ]

HEALTHCHECK --interval=30s --timeout=4s --start-period=20s --retries=3\
    CMD curl -f http://localhost:8000/health || exit 1

CMD [ "gunicorn", "app.main:app", "-k", "uvicorn.workers.UvicornWorker", "-b", "0.0.0.0:8000", "--workers", "3" ]