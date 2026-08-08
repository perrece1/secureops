# ==========================================
# Stage 1: Build Dependencies
# ==========================================
FROM python:3.11-slim AS builder

# Evita que Python escriba archivos .pyc e inhabilita el buffer de logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Instalamos las dependencias directamente en /root/.local mediante --user
RUN pip install --no-cache-dir --user -r requirements.txt

# ==========================================
# Stage 2: Hardened Runtime Environment
# ==========================================
FROM python:3.11-slim AS runner

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    # Incluimos la ruta de los ejecutable de Python en el PATH global
    PATH="/home/appuser/.local/bin:$PATH"

# Crear grupo y usuario del sistema con UID/GID explícitos no privilegiados
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /sbin/nologin -m appuser

# Copiar UNICAMENTE los binarios y dependencias procesados en el builder al home del usuario
COPY --from=builder /root/.local /home/appuser/.local

# Copiar el código fuente con permisos restringidos
COPY --chown=appuser:appgroup main.py .

# Asignar propiedad explícita de las dependencias instaladas
RUN chown -R appuser:appgroup /home/appuser/.local

USER 10001:10001

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
