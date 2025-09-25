# Use Debian slim as base (Python installed manually)
FROM debian:bookworm-slim

# Install system dependencies and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip python3-dev \
    gcc libffi-dev ffmpeg aria2 make g++ cmake wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Create a Python virtual environment
RUN python3 -m venv /opt/venv
# Make venv's bin folder default in PATH
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install Python dependencies in venv
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

# Expose port for Gunicorn
EXPOSE 8000

# Run Gunicorn + your Python script
CMD ["sh", "-c", "gunicorn app:app --bind 0.0.0.0:8000 & python3 modules/main.py"]
