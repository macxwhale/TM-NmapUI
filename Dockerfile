# Use Node.js 20 as base image
FROM node:20

# Install system dependencies
# - nmap: for network scanning
# - xsltproc: for transforming nmap XML to HTML
# - python3: for google drive integration
# - chromium: for PDF generation (replaces wkhtmltopdf for better results)
# - wkhtmltopdf: fallback for PDF generation
# - golang: required to build gowitness
# - git: required for go install
RUN apt-get update && apt-get install -y \
    nmap \
    xsltproc \
    python3 \
    python3-pip \
    python3-cryptography \
    chromium \
    wkhtmltopdf \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install gowitness via direct binary download (faster and more reliable than building)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then GOWIT_ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then GOWIT_ARCH="arm64"; \
    else GOWIT_ARCH="arm"; fi && \
    curl -L -o /usr/local/bin/gowitness "https://github.com/sensepost/gowitness/releases/download/3.1.1/gowitness-3.1.1-linux-$GOWIT_ARCH" && \
    chmod +x /usr/local/bin/gowitness

# Set environment variables for tool paths
ENV CHROME_PATH=/usr/bin/chromium
ENV GOWITNESS_PATH=/usr/local/bin/gowitness

# Create and set working directory
WORKDIR /app

# Copy package files and install dependencies
# We do this before copying the rest of the code to leverage Docker cache
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the application port
EXPOSE 9000

# Start the application
# Note: server.js handles missing dependencies via prestart script
CMD ["npm", "start"]
