pipeline {
  agent any

  environment {
    // ===== User Specific =====
    DOCKER_USER = "vijayganesh5"
    DOCKERHUB_CREDENTIALS_ID = "docker-hub-creds"
    DEV_REPO = "${DOCKER_USER}/devops-build-dev"
    PROD_REPO = "${DOCKER_USER}/devops-build-prod"

    // ===== AWS EC2 =====
    DEVOPS_IP = "13.127.173.163"
    DEVOPS_SSH_CREDS = "ec2-ssh-key"

    // ===== Info =====
    AWS_ACCOUNT_ID = "377728961900"
    AWS_REGION = "ap-south-1"
  }

  stages {
    stage('Checkout Code') {
      steps {
        echo "Ì≥• Checking out source code from GitHub..."
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        echo "Ìª†Ô∏è Building Docker image..."
        sh 'docker build -t $DEV_REPO:latest .'
      }
    }

    stage('Push & Deploy to DEV Environment') {
      when { branch 'dev' }
      steps {
        script {
          echo "Ì∫Ä Starting DEV deployment pipeline..."

          // Step 1: Push to DockerHub
          withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}",
                                            usernameVariable: 'DBUSER',
                                            passwordVariable: 'DBPASS')]) {
            sh '''
              echo "Ì¥ë Logging into Docker Hub..."
              echo "$DBPASS" | docker login -u "$DBUSER" --password-stdin
              docker push $DEV_REPO:latest
              docker logout
            '''

            // Step 2: Copy and run deploy.sh on EC2
            echo "Ì≥¶ Deploying DEV image to EC2 ($DEVOPS_IP)..."
            sh '''
              scp -o StrictHostKeyChecking=no ./deploy.sh ubuntu@$DEVOPS_IP:/home/ubuntu/deploy.sh
              ssh -o StrictHostKeyChecking=no ubuntu@$DEVOPS_IP "chmod +x /home/ubuntu/deploy.sh && \
                DOCKER_USER=$DBUSER DOCKER_PASS=$DBPASS bash /home/ubuntu/deploy.sh dev $DEVOPS_IP"
            '''
          }
        }
      }
    }

    stage('Push & Deploy to PROD Environment') {
      when { branch 'main' }
      steps {
        script {
          echo "Ì∫Ä Starting PROD deployment pipeline..."

          // Step 1: Tag for PROD
          sh 'docker tag $DEV_REPO:latest $PROD_REPO:latest'

          // Step 2: Push to DockerHub
          withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}",
                                            usernameVariable: 'DBUSER',
                                            passwordVariable: 'DBPASS')]) {
            sh '''
              echo "Ì¥ë Logging into Docker Hub..."
              echo "$DBPASS" | docker login -u "$DBUSER" --password-stdin
              docker push $PROD_REPO:latest
              docker logout

              echo "Ì≥¶ Deploying PROD image to EC2 ($DEVOPS_IP)..."
              scp -o StrictHostKeyChecking=no ./deploy.sh ubuntu@$DEVOPS_IP:/home/ubuntu/deploy.sh
              ssh -o StrictHostKeyChecking=no ubuntu@$DEVOPS_IP "chmod +x /home/ubuntu/deploy.sh && \
                DOCKER_USER=$DBUSER DOCKER_PASS=$DBPASS bash /home/ubuntu/deploy.sh main $DEVOPS_IP"
            '''
          }
        }
      }
    }
  }

  post {
    success { echo "‚úÖ Jenkins pipeline completed successfully!" }
    failure { echo "‚ùå Pipeline failed ‚Äî please check logs for details." }
  }
}

