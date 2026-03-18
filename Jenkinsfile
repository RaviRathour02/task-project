pipeline {
  agent any

  environment {
    APP_NAME = "sample-app"
    VERSION  = "${BUILD_NUMBER}"
  }

  stages {

    stage('Checkout') {
      steps {
        git credentialsId: 'github-pat', url: 'https://github.com/RaviRathour02/java-project.git',branch: 'main'
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
        sh 'mvn verify -Pfunctional'
      }
    }

    stage('Performance Tests') {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            sh 'jmeter -n -t perf.jmx -l perf.jtl'
                }
            }
        }
    
    stage('SonarQube Scan') {
      environment {
        SONAR_TOKEN = credentials('sonar-creds')
      }
      steps {
        sh '''
          mvn sonar:sonar \
          -Dsonar.projectKey=${APP_NAME} \
          -Dsonar.host.url=http://13.201.28.158:9000 \
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


    }
}
