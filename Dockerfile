# # Us# Base image
FROM python:3.12-alpine3.20

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the code
COPY . .

# Install system dependencies
RUN apk add --no-cache \
    gcc \
    g++ \
    musl-dev \
    libffi-dev \
    ffmpeg \
    make \
    aria2

# Expose port for Koyeb health check
EXPOSE 8080

# Start the app (Koyeb uses $PORT)
CMD ["sh", "-c", "gunicorn -w 4 -b 0.0.0.0:${PORT:-8080} app:app"]
