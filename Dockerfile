# Stage 1: Build Stage
# Use a lightweight official Python image
FROM python:3.11-slim AS builder

# Set the working directory
WORKDIR /usr/src/app

# Install dependencies first
COPY requirements.txt .
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*
# Install Gunicorn for a robust production server
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final Image (Keep it minimal)
# Reuse the same base image for consistency, but you could use a 'scratch' base if all dependencies are statically compiled
FROM python:3.11-slim

# Set the working directory
WORKDIR /usr/src/app

# Copy the installed dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

# Copy the application source code
# Assuming your Flask app entry point is 'app.py'
COPY . .

# Expose the port your Flask application will run on (default 5000)
EXPOSE 3000

# Run the application using Gunicorn. 
# 'app:app' means the callable 'app' inside the file 'app.py'
CMD ["gunicorn", "--bind", "0.0.0.0:3000", "app:app"]
