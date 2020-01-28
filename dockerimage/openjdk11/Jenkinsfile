pipeline {
  options {
    ansiColor('xterm')
  }   
  environment {
    registry           = "hub.docker.com/dksha17/java"
    registryCredential = 'Chandigarh@1'
    dockerImage        = ''
  }
  agent any
  stages {
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build(registry + "/ubuntu/openjdk:11.x", "-f docker_baseimages/openjdk11/Dockerfile .")
        }
      }
    }
    
    stage('push Image to acr') {
      steps{
        script {
          docker.withRegistry( 'https://' + registry, registryCredential ) {
          dockerImage.push()
          }
        }
      }
    }
  }
}
