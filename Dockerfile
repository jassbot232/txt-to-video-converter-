# Debian slim with Python
FROM debian:bookworm-slim

# Install system + Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-dev \
    gcc libffi-dev ffmpeg aria2 make g++ cmake wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Copy all files
COPY . .

# Install Python deps
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir -r sainibots.txt \
    && pip3 install --no-cache-dir -U yt-dlp

# Build and install Bento4 (mp4decrypt)
RUN wget -q https://github.com/axiomatic-systems/Bento4/archive/v1.6.0-639.zip \
    && unzip v1.6.0-639.zip \
    && cd Bento4-1.6.0-639 && mkdir build && cd build \
    && cmake .. && make -j$(nproc) \
    && cp mp4decrypt /usr/local/bin/ \
    && cd ../.. && rm -rf Bento4-1.6.0-639 v1.6.0-639.zip

EXPOSE 8000
CMD ["sh", "-c", "gunicorn app:app --bind 0.0.0.0:8000 & python3 modules/main.py"]
