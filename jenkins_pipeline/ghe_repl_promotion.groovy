pipeline {
    agent { node { label 'master' } }
    options {
        ansiColor('xterm')
    }
    parameters {
        string(name: 'host', defaultValue: '', description: 'enter replica ip address')
    }
    environment {

        // The APPROVERS env var is used to determine who can approve
        APPROVERS   = "******"
    }
    stages {
        stage('promote replica') {
            steps {
                echo "Component: per_environment_addresses\nAction: ${params.action}"
                    script {
                        input(message: "\nWARNING! you are about to promote replica as primary ghe! Is this what you intend to do?", submitter: "${env.APPROVERS}")
                        sh "ssh -p 122 admin@${host} 'ghe-repl-promote'"
                        }
                    }
                }
            }        
    // Post describes the steps to take when the pipeline finishes
    post {
        always {
            echo "Clearing workspace"
            deleteDir() // Clean up the local workspace so we don't leave behind a mess, or sensitive files
        }
    }
}
