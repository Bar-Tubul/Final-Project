# Use an official Python runtime as a parent image
FROM python:3.12.3

# Create application directory
RUN mkdir -p /opt/status-page

# Set the working directory
WORKDIR /opt/status-page

# Copy the current directory contents into the container
COPY . .

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libxml2-dev \
    libxslt1-dev \
    libffi-dev \
    libpq-dev \
    libssl-dev \
    zlib1g-dev && \
 
# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the app will run on
EXPOSE 8001

# Default command to run Gunicorn
CMD ["gunicorn", "--pid", "/var/tmp/status-page.pid", "--pythonpath", "/opt/status-page/statuspage", "--config", "/opt/status-page/gunicorn.py", "statuspage.wsgi:application", "--bind", "0.0.0.0:8001"]
