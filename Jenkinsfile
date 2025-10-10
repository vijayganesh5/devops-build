pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "vijayganesh5"
        DEV_REPO = "vijayganesh5/devops-build-dev"
        PROD_REPO = "vijayganesh5/devops-build-prod"
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/vijayganesh5/devops-build.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Ìª†Ô∏è Building Docker image for branch: ${env.BRANCH_NAME}"

                    if (env.BRANCH_NAME == 'dev') {
                        docker.build("${DEV_REPO}:latest")
                    } else if (env.BRANCH_NAME == 'master') {
                        docker.build("${PROD_REPO}:latest")
                    } else {
                        error("‚ùå Unsupported branch: ${env.BRANCH_NAME}. Use 'dev' or 'master' only.")
                    }
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    echo "Ì≥§ Pushing image to DockerHub..."

                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
                        if (env.BRANCH_NAME == 'dev') {
                            docker.image("${DEV_REPO}:latest").push()
                        } else if (env.BRANCH_NAME == 'master') {
                            docker.image("${PROD_REPO}:latest").push()
                        }
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "Ì∫Ä Deploying to EC2..."
                    sh './deploy.sh'
                }
            }
        }
    }

    post {
        success {
            echo "‚úÖ Pipeline completed successfully!"
        }
        failure {
            echo "‚ùå Pipeline failed. Please check the logs."
        }
    }
}

