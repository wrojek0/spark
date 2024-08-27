# Dockerfile based on bitnami/spark:3.1.2

# Use bitnami/spark as the base image
FROM bitnami/spark:3.1.2

# Switch to root user for installation
USER root

# Update apt-get and install necessary packages
RUN apt-get update \
    && apt-get install -y \
        python3-pip \
        python3-setuptools \
        python3-dev \
        build-essential \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir \
        numpy \
        pandas \
        keras \
        tensorflow \
        jupyter \
        matplotlib 

# Set up a working directory
WORKDIR /app


#COPY network-malware-detection-connection-analysis.zip .

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
