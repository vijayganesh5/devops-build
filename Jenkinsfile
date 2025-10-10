pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        EC2_HOST = 'ec2-13-127-173-163.ap-south-1.compute.amazonaws.com'
        DOCKER_USER = 'vijayganesh5' // your Docker Hub username
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
                    withCredentials([string(credentialsId: 'docker-hub-pass', variable: 'DOCKER_PASS')]) {
                        // Detect branch properly
                        def branch = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                        echo "Ì¥ñ Branch detected: ${branch}"

                        // Build and push Docker image
                        sh "./build.sh ${branch} $DOCKER_USER $DOCKER_PASS"
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'EC2_KEY')
                    ]) {
                        def branch = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                        
                        // Pass Docker credentials and SSH key to deploy.sh
                        sh "./deploy.sh ${branch} $EC2_HOST $DOCKER_USER $DOCKER_PASS $EC2_KEY"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "‚úÖ Pipeline completed successfully for branch ${env.BRANCH_NAME}!"
        }
        failure {
            echo "‚ùå Pipeline failed! Check logs for details."
        }
    }
}

