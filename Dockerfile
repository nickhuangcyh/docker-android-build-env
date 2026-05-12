FROM eclipse-temurin:21-jdk-jammy

LABEL maintainer="NickHuang <nickhuang@climax.com.tw>"

ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH=${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git zip unzip curl wget python3 \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 17
RUN mkdir -p /usr/lib/jvm/java-17-openjdk-amd64 \
    && curl -fsSL "https://api.adoptium.net/v3/binary/latest/17/ga/linux/x64/jdk/hotspot/normal/eclipse" -o /tmp/jdk17.tar.gz \
    && tar -xzf /tmp/jdk17.tar.gz -C /usr/lib/jvm/java-17-openjdk-amd64 --strip-components=1 \
    && rm /tmp/jdk17.tar.gz

# Install JDK 11
RUN mkdir -p /usr/lib/jvm/java-11-openjdk-amd64 \
    && curl -fsSL "https://api.adoptium.net/v3/binary/latest/11/ga/linux/x64/jdk/hotspot/normal/eclipse" -o /tmp/jdk11.tar.gz \
    && tar -xzf /tmp/jdk11.tar.gz -C /usr/lib/jvm/java-11-openjdk-amd64 --strip-components=1 \
    && rm /tmp/jdk11.tar.gz

# JDK 21 is already the base image's JDK, symlink it
RUN ln -sf /opt/java/openjdk /usr/lib/jvm/java-21-openjdk-amd64

# Install Android Command Line Tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -o /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

# Accept licenses and install SDK components
RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-28" "platforms;android-34" "ndk;27.0.12077973" "build-tools;34.0.0" \
    && chmod -R 777 ${ANDROID_HOME}

# Install rclone
RUN curl -fsSL -o /tmp/rclone.deb https://downloads.rclone.org/rclone-current-linux-amd64.deb \
    && dpkg -i /tmp/rclone.deb \
    && rm /tmp/rclone.deb

# Gradle cache directory (writable by any uid, since Jenkins runs container with host uid)
RUN mkdir -p /opt/gradle-cache /tmp/.android && chmod 777 /opt/gradle-cache /tmp/.android
ENV GRADLE_USER_HOME=/opt/gradle-cache
ENV ANDROID_USER_HOME=/tmp/.android
