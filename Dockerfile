# Use the base image with Java 11 from Eclipse Temurin
FROM eclipse-temurin:11-jre-jammy

# Set environment variables
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

# Create the Tomcat home directory and set the working directory
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# Set environment variables related to Tomcat Native
ENV TOMCAT_NATIVE_LIBDIR $CATALINA_HOME/native-jni-lib
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$TOMCAT_NATIVE_LIBDIR

# Set GPG keys for Tomcat downloads (you might want to update these keys if needed)
ENV GPG_KEYS <insert-gpg-keys-here>

# Set Tomcat version and SHA-512 checksum (you might want to update these values if needed)
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.93
ENV TOMCAT_SHA512 <insert-sha512-checksum-here>

# Copy Tomcat binaries from another image (make sure this image exists)
COPY --from=tomcat:8.5.93-jdk11-temurin-jammy $CATALINA_HOME $CATALINA_HOME

# Install dependencies and clean up apt-get cache
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends < "$TOMCAT_NATIVE_LIBDIR/.dependencies.txt"; \
	rm -rf /var/lib/apt/lists/*

# Verify Tomcat Native is working properly
RUN set -eux; \
	nativeLines="$(catalina.sh configtest 2>&1)"; \
	nativeLines="$(echo "$nativeLines" | grep 'Apache Tomcat Native')"; \
	nativeLines="$(echo "$nativeLines" | sort -u)"; \
	if ! echo "$nativeLines" | grep -E 'INFO: Loaded( APR based)? Apache Tomcat Native library' >&2; then \
		echo >&2 "$nativeLines"; \
		exit 1; \
	fi

# Expose port 8080 for Tomcat
EXPOSE 8080

# Clear the entrypoint and set the default command to start Tomcat
ENTRYPOINT []
CMD ["catalina.sh", "run"]
