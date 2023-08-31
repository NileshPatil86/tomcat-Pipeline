# Use an official OpenJDK image as the base image
FROM openjdk:8-jdk-slim

# Set environment variables for Tomcat version and installation path
ENV TOMCAT_MAJOR_VERSION=9 \
    TOMCAT_MINOR_VERSION=9.0.54 \
    CATALINA_HOME=/opt/tomcat

# Create a directory for Tomcat installation
RUN mkdir -p $CATALINA_HOME

# Download and extract Tomcat
RUN apt-get update && apt-get install -y wget && \
    wget -q http://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR_VERSION/v$TOMCAT_MINOR_VERSION/bin/apache-tomcat-$TOMCAT_MINOR_VERSION.tar.gz && \
    tar -xzf apache-tomcat-$TOMCAT_MINOR_VERSION.tar.gz -C $CATALINA_HOME --strip-components=1 && \
    rm apache-tomcat-$TOMCAT_MINOR_VERSION.tar.gz && \
    rm -rf $CATALINA_HOME/webapps/*

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["$CATALINA_HOME/bin/catalina.sh", "run"]
