# Hadolint ignore=DL3008,DL3009,DL3015
# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variables to avoid prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages: Python 3.10, git, and other dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common git curl && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-venv python3.10-dev

# Set Python 3.10 as the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Install pip
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py

# Change working directory
WORKDIR /app/statuspage
COPY ./statuspage /app/statuspage

# Expose any necessary ports (adjust based on your app)
EXPOSE 8001

# Run the dependence for the application
RUN bash upgrade.sh

# Change the working directory for the application entry point
WORKDIR /app/statuspage/statuspage

# Define the entry point to run your app using Gunicorn
CMD ["/app/statuspage/venv/bin/gunicorn", "-b", "0.0.0.0:8001", "-c", "/app/statuspage/gunicorn.py", "statuspage.wsgi:application"]
