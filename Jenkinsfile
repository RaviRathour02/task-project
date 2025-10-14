pipeline{
  agent any

  stages{
    stage("Build"){
      steps {
        sh "mvn -B validate --file pom.xml"
      }
    }
  }
}
