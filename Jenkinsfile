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
        // Debug: Print branch information
        sh 'echo "Current branch: $BRANCH_NAME"'
        sh 'git branch -a'
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
          branch 'origin/dev'
          expression { env.GIT_BRANCH == 'origin/dev' }
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
            sh "ssh -o StrictHostKeyChecking=no ubuntu@$DEVOPS_IP 'cd ~/project && docker-compose down && docker-compose up -d'"
          }
        }
      }
    }

    stage('Push & Deploy Prod') {
      when { 
        anyOf {
          branch 'main'
          branch 'master' 
          branch 'origin/main'
          branch 'origin/master'
          expression { env.GIT_BRANCH == 'origin/main' }
          expression { env.BRANCH_NAME == 'main' }
        }
      }
      steps {
        script {
          echo "Running Push & Deploy Prod on branch: ${env.BRANCH_NAME}"
          
          // 1. TAG FOR PROD
          echo "1. Tagging DEV image for PROD repo..."
          sh 'docker tag $DEV_REPO:latest $PROD_REPO:latest'
          
          // 2. PUSH TO DOCKERHUB PROD REPO
          echo "2. Pushing to DockerHub PROD private repo..."
          withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", usernameVariable: 'DBUSER', passwordVariable: 'DBPASS')]) {
            sh '''
              echo "$DBPASS" | docker login -u "$DBUSER" --password-stdin
              docker push $PROD_REPO:latest
              docker logout
            '''
          }
          
          // 3. DEPLOY PROD IMAGE VIA SSH
          echo "3. Deploying PROD image to DevOps EC2 at $DEVOPS_IP..."
          sshagent(credentials: ["${DEVOPS_SSH_CREDS}"]) { 
            sh "ssh -o StrictHostKeyChecking=no ubuntu@$DEVOPS_IP 'cd ~/project && docker-compose -f docker-compose.prod.yml down && docker-compose -f docker-compose.prod.yml up -d'" 
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
