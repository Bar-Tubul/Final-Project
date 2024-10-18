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

# Clone the Git repository
RUN git clone https://github.com/peervetzler/Final-Project.git /app

# Change working directory
WORKDIR /app/status-page-application

# Install Python dependencies
RUN pip install -r requirements.txt

# Expose any necessary ports (adjust based on your app)
EXPOSE 8001

# Define the entry point to run your app
CMD ["bash", "upgrade.sh"]

# Define the entry point to run your app using Gunicorn
WORKDIR /app/status-page-application/statuspage

RUN python3 manage.py createsuperuser --noinput --username '<<name>>' --email '<<gmail>>' && \
    echo "from django.contrib.auth import get_user_model; User = get_user_model(); user = User.objects.get(username='<<name>>'); user.set_password('<<password>>'); user.save()" | python3 manage.py shell

#Define the entry point to run your app using Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:8001", "-c", "/app/status-page-application/gunicorn.py", "statuspage.wsgi:application"]
