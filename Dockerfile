# Dockerfile for cloudmapper

FROM amazonlinux:2

MAINTAINER Amit Halder

# Install required packages
RUN yum -y update && \
    yum -y install python3 git && \
    curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm -rf awscliv2.zip ./aws && \
    yum clean all

# Install other dependencies
RUN yum -y install autoconf automake libtool python3-dev

# Clone CloudMapper repository and install requirements
RUN git clone https://github.com/duo-labs/cloudmapper.git && \
    cd cloudmapper/ && \
    pip3 install -r requirements.txt

WORKDIR /cloudmapper/

# Copy credentials and config file
COPY credentials /root/.aws/credentials
COPY config.json config.json

# Run CloudMapper commands
RUN python3 cloudmapper.py collect --config config.json && \
    python3 cloudmapper.py prepare --config config.json

# Set entrypoint for CloudMapper webserver
ENTRYPOINT ["python3", "cloudmapper.py", "webserver", "--public"]

# Expose port 8000
EXPOSE 8000
