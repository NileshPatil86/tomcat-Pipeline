# Use the official Amazon Linux image as the base
FROM amazonlinux:latest

# Set environment variables for Tomcat version and installation path
ENV TOMCAT_MAJOR_VERSION=9 \
    TOMCAT_MINOR_VERSION=9.0.54 \
    CATALINA_HOME=/opt/tomcat

# Install required packages
RUN yum update -y && \
    yum install -y java-1.8.0-openjdk wget && \
    yum clean all

# Create a directory for Tomcat installation
RUN mkdir -p $CATALINA_HOME

# Download and extract Tomcat
RUN wget -q http://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR_VERSION/v$TOMCAT_MINOR_VERSION/bin/apache-tomcat-$TOMCAT_MINOR_VERSION.tar.gz && \
    tar -xzf apache-tomcat-$TOMCAT_MINOR_VERSION.tar.gz -C $CATALINA_HOME --strip-components=1 && \
    rm apache-tomcat-$TOMCAT_MINOR_VERSION.tar.gz && \
    rm -rf $CATALINA_HOME/webapps/*

# Expose the default Tomcat port
EXPOSE 8080

# Allow Docker user inside the container (optional, for demonstration purposes)
ARG DOCKER_UID=1000
ARG DOCKER_GID=1000
RUN groupadd -g $DOCKER_GID docker && \
    useradd -u $DOCKER_UID -g $DOCKER_GID -m docker

# Start Tomcat
CMD ["$CATALINA_HOME/bin/catalina.sh", "run"]
