# docker-android-build-env

Docker image for Android CI builds with multi-JDK (11/17/21) and Android SDK support.

## Usage

### As Jenkins Docker Agent

```groovy
pipeline {
    agent {
        docker {
            image 'ghcr.io/nickhuangcyh/docker-android-build-env:latest'
            args '-v gradle-cache:/home/jenkins/.gradle'
        }
    }
    // ...
}
```

### Volume Mount (recommended)

Mount a volume for Gradle cache to avoid re-downloading dependencies on every build:

```
-v gradle-cache:/home/jenkins/.gradle
```

## Included

- JDK 11 / 17 / 21 (Adoptium Temurin)
- Android SDK (platforms 28, 34)
- Android NDK 27.0.12077973
- Build Tools 34.0.0
- rclone

## Build & Publish

Push a git tag to trigger the GitHub Actions workflow, which builds and pushes the image to GHCR.

```bash
git tag v1.0.0
git push origin v1.0.0
```

Image will be available at:
```
ghcr.io/nickhuangcyh/docker-android-build-env:v1.0.0
```
