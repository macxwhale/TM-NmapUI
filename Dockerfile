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
    golang \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install gowitness via Go
RUN go install github.com/sensepost/gowitness@latest
ENV PATH="/root/go/bin:${PATH}"

# Set environment variables for tool paths
ENV CHROME_PATH=/usr/bin/chromium
ENV GOWITNESS_PATH=/root/go/bin/gowitness

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
