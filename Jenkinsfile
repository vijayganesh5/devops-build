pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        EC2_HOST = 'ec2-13-127-173-163.ap-south-1.compute.amazonaws.com'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Ì≥• Checking out source code..."
                checkout scm
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', 
                                                     usernameVariable: 'DOCKER_USER', 
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh 'chmod +x ./build.sh'
                        sh "./build.sh ${env.BRANCH_NAME} $DOCKER_USER $DOCKER_PASS"
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', 
                                                       keyFileVariable: 'EC2_PRIVATE_KEY', 
                                                       usernameVariable: 'EC2_USER')]) {
                        sh 'chmod +x ./deploy.sh'
                        sh "./deploy.sh ${env.BRANCH_NAME} $EC2_HOST"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "‚úÖ Pipeline completed successfully for ${env.BRANCH_NAME}!"
        }
        failure {
            echo "‚ùå Pipeline failed! Check logs for details."
        }
    }
}

