pipeline {
  options {
    ansiColor('xterm')
  }    
  environment {
    registry           = "*****"
    registryCredential = '******'
    dockerImage        = ''
  }
  agent { 
    label 'tenable_cs'
  }
  stages {
    //stage('Checkout from git') {
    //  steps {
    //    dir ("/home/github-dev"){
    //      checkout scm: [
     //       $class: 'GitSCM', userRemoteConfigs: [
      //        [
       //         url: 'git@dev-github.albertsons.com:albertsons/platform-app-support.git',
       //         credentialsId: '****',
       //         changelog: false,
        //      ]
         //   ],
         //   poll: false
         // ]
       // }
      //}
    //}

    stage('Build') {
      steps {
         sh 'npm install'
       }
    }

    stage('Test') {
      steps {
        sh 'npm test'
      }
    }

    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build registry + "/nodejs/node:$BUILD_NUMBER"
        }
      }
    }

    stage('Deploy Image') {
      steps{
        script {
          docker.withRegistry( 'https://' + registry, registryCredential ) {
          dockerImage.push()
          }
        }
      }
    }
    
    stage('check policy compliance') {
      steps{
          withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: '*****', usernameVariable: 'ACCESS_KEY', passwordVariable: 'SECRET_KEY']]) {
            sh '''
              image_id=$(docker images  $registry/nodejs/node:$BUILD_NUMBER -q)
              sleep 30
              image_status=$(curl -H "X-Apikeys: accessKey=$ACCESS_KEY;secretKey=$SECRET_KEY" https://cloud.tenable.com/container-security/api/v1/policycompliance?image_id=$image_id | jq -r '.status')
              csup --access-key $ACCESS_KEY --secret-key $SECRET_KEY report $image_id
              echo "Image status is:" $image_status
              if [ $image_status != "pass" ]; then
                echo "Image has not passed the compliance plolicy"
                exit 1
              else:
                echo "Image has passed the compliance plolicy"
                exit 0
              fi
            '''
          }
      }
    }

    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $registry/nodejs/node:$BUILD_NUMBER"
      }
    }
  }
}
