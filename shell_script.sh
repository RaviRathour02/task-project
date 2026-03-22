#!/bin/bash
set -e

############################
# Variables (from Jenkins env)
############################
APP_NAME="sample-app"
VERSION="${BUILD_NUMBER:-1}"     # fallback if not running in Jenkins
IMAGE_NAME="java-app"
IMAGE_TAG="latest"
NEXUS_REGISTRY="13.127.72.63:8082"

# Sonar
SONAR_PROJECT_KEY="my-app"
SONAR_HOST_URL="http://3.108.190.52:8080"

# Git
GIT_URL="https://github.com/RaviRathour02/task-project.git"
GIT_BRANCH="main"


############################
# Helper
############################
log() {
  echo "=============================="
  echo "$1"
  echo "=============================="
}

############################
# Checkout
############################
log "Checkout Source Code"
rm -rf repo
git clone -b "$GIT_BRANCH" "$GIT_URL" repo
cd repo

############################
# Checkout
############################
log "Checkout Source Code"
rm -rf repo
git clone -b "$GIT_BRANCH" "$GIT_URL" repo
cd repo

############################
# Maven Build
############################
log "Maven Build"
mvn clean compile

############################
# Unit Tests
############################
log "Unit Tests"
mvn test

############################
# Functional Tests
############################
log "Functional Tests"
mvn verify -Pfunctional-tests

############################
# Performance Tests
############################
log "Performance Tests"
mvn verify -Pperformance-tests

############################
# SonarQube Scan
############################
log "SonarQube Scan"
mvn sonar:sonar \
  -Dsonar.projectKey="$SONAR_PROJECT_KEY" \
  -Dsonar.host.url="$SONAR_HOST_URL" \
  -Dsonar.login="$SONAR_TOKEN"

############################
# Docker Build
############################
log "Docker Build"
docker build -t "$NEXUS_REGISTRY/$IMAGE_NAME:$IMAGE_TAG" .

############################
# Docker Push to Nexus
############################
log "Docker Login & Push"
echo "$NEXUS_PASS" | docker login "$NEXUS_REGISTRY" \
  -u "$NEXUS_USER" --password-stdin

docker push "$NEXUS_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

log "Pipeline completed successfully ✅"
                                                
