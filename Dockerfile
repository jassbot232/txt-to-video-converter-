# Use a stable Python 3.12 slim base image
FROM python:3.12-slim

# Set the working directory
WORKDIR /app

# Copy all files into container
COPY . .

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libffi-dev \
    ffmpeg \
    aria2 \
    make \
    g++ \
    cmake \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Build and install Bento4 (mp4decrypt)
RUN wget -q https://github.com/axiomatic-systems/Bento4/archive/v1.6.0-639.zip && \
    unzip v1.6.0-639.zip && \
    cd Bento4-1.6.0-639 && \
    mkdir build && cd build && \
    cmake .. && make -j$(nproc) && \
    cp mp4decrypt /usr/local/bin/ && \
    cd ../.. && rm -rf Bento4-1.6.0-639 v1.6.0-639.zip

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r sainibots.txt \
    && pip install --no-cache-dir -U yt-dlp

# Expose port for Gunicorn
EXPOSE 8000

# Run Gunicorn + your Python script
CMD ["sh", "-c", "gunicorn app:app --bind 0.0.0.0:8000 & python3 modules/main.py"]
