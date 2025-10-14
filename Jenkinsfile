pipeline{
  agent any

  stages{
    stage("Build"){
      steps {
        sh "mvn clean -X install --file pom.xml"
      }
    }
  }
}
