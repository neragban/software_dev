# Use Python 3.11 slim image optimized for ARM architecture (Raspberry Pi)
FROM python:3.11-slim-bullseye

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Create app directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY "Multi-Thread Port Scanner.py" ./port_scanner.py

# Create directory for scan results
RUN mkdir -p /app/results

# Set permissions
RUN chmod +x /app/port_scanner.py

# Create a non-root user for security
RUN useradd -m -u 1000 scanner && \
    chown -R scanner:scanner /app

USER scanner

# Expose no specific ports as this is a scanning tool
# The container will run interactively

# Default command to run the scanner
CMD ["python", "port_scanner.py"]