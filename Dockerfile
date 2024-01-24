# Dockerfile for cloudmapper

FROM amazonlinux:2

MAINTAINER Amit Halder

# Install required packages
RUN /bin/bash -c 'yum -y update && \
    yum -y install python3 unzip git && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip ./aws'

# Install other dependencies
RUN yum -y install autoconf automake libtool python3-dev make gcc python3-devel ruby
RUN yum -y install python3-pip


# Clone CloudMapper repository and install requirements
RUN git clone https://github.com/amithalder21/cloudmapper.git && \
    cd cloudmapper/ && \
    python3 -m pip install -r requirements.txt || (echo "Error cloning or installing dependencies"; exit 1)


WORKDIR /cloudmapper/

# Copy credentials and config file
COPY credentials /root/.aws/credentials
COPY config.json config.json

# Run CloudMapper commands
RUN python3 cloudmapper.py collect --config config.json && \
    python3 cloudmapper.py prepare --config config.json --account "$CLIENT_EXTERNAL_ID" && \
    python3 cloudmapper.py report --config config.json --account "$CLIENT_EXTERNAL_ID"

# Set entrypoint for CloudMapper webserver
ENTRYPOINT ["python3", "cloudmapper.py", "webserver", "--public"]

# Expose port 8000
EXPOSE 8000
