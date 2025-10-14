pipeline{
  agent any

  stages{
    stage("Build"){
      steps {
        sh "mvn -B compile --file pom.xml"
      }
    }
  }
}
