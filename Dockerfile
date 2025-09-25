# Use Python 3.12 Alpine base image
FROM python:3.12-alpine3.20

# Set working directory
WORKDIR /app

# Copy all files to container
COPY . .

# Install dependencies
RUN apk add --no-cache \
    gcc \
    g++ \
    musl-dev \
    libffi-dev \
    ffmpeg \
    make \
    aria2 \
    && pip install --no-cache-dir -r requirements.txt

# Expose port (optional, Koyeb sets it via env)
EXPOSE 8080

# Start command using PORT env variable (default 8080)
CMD ["sh", "-c", "gunicorn -w 4 -b 0.0.0.0:${PORT:-8080} main:app"]
