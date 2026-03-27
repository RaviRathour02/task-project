pipeline {
  agent any

  environment {
    APP_NAME = "sample-app"
    VERSION  = "${BUILD_NUMBER}"
    NEXUS_REGISTRY = "nexus.example.com:8083"
    JFROG_REGISTRY = "jfrog.example.com"
  }

  stages {

    stage('Checkout') {
      steps {
        git credentialsId: 'git-creds', url: 'https://git.repo/app.git'
      }
    }

    stage('Maven Build') {
      steps {
        sh 'mvn clean compile'
      }
    }

    stage('Unit Tests') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Functional Tests') {
      steps {
        sh 'mvn verify -Pfunctional-tests'
      }
    }

    stage('Performance Tests') {
      steps {
        sh 'mvn verify -Pperformance-tests'
      }
    }

    stage('SonarQube Scan') {
      environment {
        SONAR_TOKEN = credentials('sonar-token')
      }
      steps {
        sh '''
          mvn sonar:sonar \
          -Dsonar.projectKey=${APP_NAME} \
          -Dsonar.login=$SONAR_TOKEN
        '''
      }
    }

    stage('Docker Build') {
      steps {
        sh '''
          docker build -t ${APP_NAME}:${VERSION} .
        '''
      }
    }

    stage('Push to Nexus') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'nexus-creds',
          usernameVariable: 'USER',
          passwordVariable: 'PASS'
        )]) {
          sh '''
            docker login ${NEXUS_REGISTRY} -u $USER -p $PASS
            docker tag ${APP_NAME}:${VERSION} ${NEXUS_REGISTRY}/${APP_NAME}:${VERSION}
            docker push ${NEXUS_REGISTRY}/${APP_NAME}:${VERSION}
          '''
        }
      }
    }

    stage('Push to JFrog') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'jfrog-creds',
          usernameVariable: 'USER',
          passwordVariable: 'PASS'
        )]) {
          sh '''
            docker login ${JFROG_REGISTRY} -u $USER -p $PASS
            docker tag ${APP_NAME}:${VERSION} ${JFROG_REGISTRY}/${APP_NAME}:${VERSION}
            docker push ${JFROG_REGISTRY}/${APP_NAME}:${VERSION}
          '''
        }
      }
    }

    stage('Update GitOps Repo') {
      steps {
        sh '''
          git clone https://git.repo/gitops.git
          cd gitops

          sed -i "s/tag:.*/tag: ${VERSION}/" helm/values-nexus.yaml
          sed -i "s/tag:.*/tag: ${VERSION}/" helm/values-jfrog.yaml

          git commit -am "Update image tag ${VERSION}"
          git push
        '''
      }
    }
  }
}
