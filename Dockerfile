# Use Python 3.12 Alpine base image
FROM python:3.12-alpine3.20

# Set working directory
WORKDIR /app

# Copy only requirements first (better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy rest of the app
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

# Expose port (optional)
EXPOSE 8080

# Start the app using Koyeb PORT env variable
CMD ["sh", "-c", "gunicorn -w 4 -b 0.0.0.0:${PORT:-8080} main:app"]
