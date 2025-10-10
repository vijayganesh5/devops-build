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
                        script {
                            // Detect branch properly
                            def branch = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                            echo "Ì¥ñ Branch detected: ${branch}"

                            // Build and push Docker image
                            sh "./build.sh ${branch} $DOCKER_USER $DOCKER_PASS"
                        }
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'devopsbuildkey.pem', 
                                                       keyFileVariable: 'EC2_PRIVATE_KEY', 
                                                       usernameVariable: 'EC2_USER')]) {
                        script {
                            def branch = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                            sh "./deploy.sh ${branch} $EC2_HOST"
                        }
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

