pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-creds')
    }

    triggers {
        githubPush()
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
                    echo "Ìª†Ô∏è Building and pushing Docker image for branch: ${env.BRANCH_NAME}"
                    
                    // Set Docker password from credentials
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "chmod +x ./build.sh"
                        sh "DOCKER_PASSWORD='${DOCKER_PASSWORD}' ./build.sh ${env.BRANCH_NAME}"
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "Ì∫Ä Deploying ${env.BRANCH_NAME} build to EC2..."
                    sh "chmod +x ./deploy.sh"
                    sh "./deploy.sh ${env.BRANCH_NAME}"
                }
            }
        }
    }

    post {
        success {
            echo "‚úÖ Pipeline completed successfully for ${env.BRANCH_NAME}!"
        }
        failure {
            echo "‚ùå Pipeline failed! Please check the logs for errors."
        }
    }
}
