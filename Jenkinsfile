pipeline{
  agent any

  stages{
    stage("Build"){
      steps {
        sh "mvn clean -B install --file pom.xml"
      }
    }
  }
}
