FROM cgr.dev/chainguard/python:latest-dev as build
# https://docs.astral.sh/uv/guides/integration/docker/#installing-a-project
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# install uv binary to build container
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock,relabel=shared \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml,relabel=shared \
    uv sync --frozen --no-install-project --no-dev

# Place executables in the environment at the front of the path
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#using-the-environment
ENV PATH="/app/.venv/bin:$PATH"

COPY ./scripts /app/scripts

COPY ./pyproject.toml ./uv.lock ./alembic.ini /app/

COPY ./app /app/app

# Sync the project
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#intermediate-layers
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

FROM cgr.dev/chainguard/python:latest AS runtime

WORKDIR /app

COPY --chown=nonroot:nonroot --from=build /app /app

ENV PYTHONUNBUFFERED=1
# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

ENTRYPOINT ["/app/.venv/bin/python"]

CMD ["-m", "fastapi", "run", "--workers", "4", "/app/app/main.py"]
