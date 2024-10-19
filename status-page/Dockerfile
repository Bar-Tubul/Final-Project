# Use an official slim Python runtime as a parent image
FROM python:3.12.3-slim

# Create application directory
RUN mkdir -p /opt/status-page

# Set the working directory
WORKDIR /opt/status-page

COPY . .

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libxml2-dev \
    libxslt1-dev \
    libffi-dev \
    libpq-dev \
    libssl-dev \
    zlib1g-dev \
    git

# Clone the specific branch of the Git repository
#RUN git clone -b Statuspage https://github.com/Bar-Tubul/Final-Project.git /opt

# Set the working directory to the application
#WORKDIR /opt/status-page-application

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the app will run on
EXPOSE 8001

# Default command to run Gunicorn
CMD ["gunicorn", "--pid", "/var/tmp/status-page.pid", "--pythonpath", "/opt/status-page/statuspage", "--config", "/opt/status-page/gunicorn.py", "statuspage.wsgi:application", "--bind", "0.0.0.0:8001"]
