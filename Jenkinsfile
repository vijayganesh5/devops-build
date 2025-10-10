pipeline {
  agent any

  environment {
    DOCKER_USER = "vijayganesh5"
    DOCKERHUB_CREDENTIALS_ID = "docker-hub-creds"
    DEV_REPO = "${DOCKER_USER}/devops-build-dev"
    PROD_REPO = "${DOCKER_USER}/devops-build-prod"
    
    DEVOPS_IP = "65.2.146.205"
    DEVOPS_SSH_CREDS = "ec2-ssh-key"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        echo "Source code checked out successfully."
        script {
          // Set branch name properly
          env.BRANCH_NAME = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
          echo "Current branch: ${env.BRANCH_NAME}"
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $DEV_REPO:latest .'
      }
    }

    stage('Push & Deploy Dev') {
      when { 
        anyOf {
          branch 'dev'
          expression { env.BRANCH_NAME == 'dev' }
        }
      }
      steps {
        script {
          echo "Running Push & Deploy Dev on branch: ${env.BRANCH_NAME}"
          
          // 1. PUSH TO DOCKERHUB DEV REPO
          echo "1. Pushing to DockerHub DEV repo..."
          withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", usernameVariable: 'DBUSER', passwordVariable: 'DBPASS')]) {
            sh '''
              echo "$DBPASS" | docker login -u "$DBUSER" --password-stdin
              docker push $DEV_REPO:latest
              docker logout
            '''
          }
          
          // 2. DEPLOY DEV IMAGE VIA SSH
          echo "2. Deploying DEV image to DevOps EC2 at $DEVOPS_IP..."
          sshagent(credentials: ["${DEVOPS_SSH_CREDS}"]) { 
            sh """
              # Pull latest image and deploy
              ssh -o StrictHostKeyChecking=no ubuntu@$DEVOPS_IP 'cd ~/devops-build && docker-compose pull && docker-compose down && docker-compose up -d'
            """
          }
        }
      }
    }

    stage('Push & Deploy Prod') {
      when { 
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        script {
          echo "Running Push & Deploy Prod on branch: ${env.BRANCH_NAME}"
          
          // 1. TAG FOR PROD
          echo "1. Tagging DEV image for PROD repo..."
          sh 'docker tag $DEV_REPO:latest $PROD_REPO:latest'
          
          // 2. PUSH TO DOCKERHUB PROD REPO
          echo "2. Pushing to DockerHub PROD repo..."
          withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", usernameVariable: 'DBUSER', passwordVariable: 'DBPASS')]) {
            sh '''
              echo "$DBPASS" | docker login -u "$DBUSER" --password-stdin
              docker push $PROD_REPO:latest
              docker logout
            '''
          }
          
          // 3. CREATE docker-compose.prod.yml AND DEPLOY
          echo "3. Deploying PROD image to DevOps EC2..."
          sshagent(credentials: ["${DEVOPS_SSH_CREDS}"]) { 
            sh """
              # Create production docker-compose file
              ssh -o StrictHostKeyChecking=no ubuntu@$DEVOPS_IP 'cat > ~/devops-build/docker-compose.prod.yml << EOF
version: '3'
services:
  react-app-prod:
    image: ${PROD_REPO}:latest
    ports:
      - "80:80"
    container_name: react-app-prod
    restart: unless-stopped
EOF'
              
              # Deploy production container
              ssh -o StrictHostKeyChecking=no ubuntu@$DEVOPS_IP 'cd ~/devops-build && docker-compose -f docker-compose.prod.yml pull && docker-compose -f docker-compose.prod.yml down && docker-compose -f docker-compose.prod.yml up -d'
            """
          }
        }
      }
    }
  }

  post {
    success { echo "✅ Pipeline completed successfully!" }
    failure { echo "❌ Pipeline failed — check build logs for errors." }
  }
}
