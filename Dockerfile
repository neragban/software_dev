# Multi-stage build: Test stage
FROM python:3.11-slim-bullseye AS test

WORKDIR /app

# Install test dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all source code
COPY . .

# Run tests
RUN pytest tests/ -v --cov=Multi_Thread_Port_Scanner --cov-report=term || true


# Multi-stage build: Final runtime stage
FROM python:3.11-slim-bullseye AS runtime

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/app:$PATH"

# Create app directory
WORKDIR /app

# Install system dependencies with minimal layers (optimized for caching)
RUN apt-get update && apt-get install -y --no-install-recommends \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements from source
COPY requirements.txt .

# Install Python dependencies with no cache (minimize layer size)
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir bandit

# Copy application code
COPY Multi_Thread_Port_Scanner.py ./port_scanner.py

# Create directory for scan results
RUN mkdir -p /app/results

# Set permissions on executable
RUN chmod +x /app/port_scanner.py

# Create a non-root user for security
RUN useradd -m -u 1000 scanner && \
    chown -R scanner:scanner /app

# Switch to non-root user
USER scanner

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import socket; socket.socket()" || exit 1

# Default command to run the scanner
CMD ["python", "port_scanner.py"]