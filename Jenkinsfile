def state_list = ["apply","destroy"]

pipeline {

    parameters {
        choice (name: 'final_tf_cmd',
            choices: state_list,
            description: 'The Final Terraform Command After init/plan'
        )
    }

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

                    ./tf-run ''' + params.final_tf_cmd + ''' DIRECT
                    '''
                }
            }
        }
    }

}