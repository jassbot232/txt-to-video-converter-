# Use Debian slim as base
FROM debian:bookworm-slim

# Install system dependencies and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip python3-dev \
    gcc g++ make cmake libffi-dev ffmpeg aria2 wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Create a Python virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r sainibots.txt \
    && pip install --no-cache-dir -U yt-dlp

# Build and install Bento4 (mp4decrypt)
RUN wget -q https://github.com/axiomatic-systems/Bento4/archive/v1.6.0-639.zip \
    && unzip v1.6.0-639.zip \
    && cd Bento4-1.6.0-639 && mkdir build && cd build \
    && cmake .. && make -j$(nproc) \
    && cp mp4decrypt /usr/local/bin/ \
    && cd ../.. && rm -rf Bento4-1.6.0-639 v1.6.0-639.zip

# Expose port Koyeb expects
EXPOSE 8080

# Run main.py first, then Gunicorn in foreground
CMD ["sh", "-c", "python3 modules/main.py & exec gunicorn app:app --bind 0.0.0.0:8080 --workers 1 --worker-class sync"]
