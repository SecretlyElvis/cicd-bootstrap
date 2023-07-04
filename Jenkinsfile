pipeline {
    
    agent { label 'Local' }

    stages {
        stage('AWS Credential Test') {
            agent {
                docker {
                    image 'jenkins-tf:latest'
                    registryUrl 'http://192.168.1.216:8082'
                    registryCredentialsId 'docker-admin'
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'neural-aws',
                    accessKeyVariable: 'ACCESS_KEY',
                    secretKeyVariable: 'SECRET_KEY'
                ]]) {
                    checkout scm

                    sh '''
                    ./tf-run init DIRECT

                    ./tf-run plan DIRECT

                    
                    '''
                }
            }
        }
    }

}