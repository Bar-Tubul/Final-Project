pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_APP_REPO = '992382545251.dkr.ecr.us-east-1.amazonaws.com/statuspage-bop'
        ECR_NGINX_REPO = '992382545251.dkr.ecr.us-east-1.amazonaws.com/nginx-bop'
        AWS_CREDENTIALS_ID = 'aws-jenkins-creds'
    }

    stages {
        stage('Build Application Image') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        // Login to ECR
                        sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_APP_REPO'

                        // Build the application Docker image
                        sh 'docker build -t statuspage-app:latest ./statuspage'

                        // Tag the image with ECR repository URL
                        sh 'docker tag statuspage-app:latest $ECR_APP_REPO:latest'

                        // Push the image to ECR
                        sh 'docker push $ECR_APP_REPO:latest'
                    }
                }
            }
        }

        stage('Build Nginx Image') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        // Login to ECR
                        sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_NGINX_REPO'

                        // Build the Nginx Docker image using Dockerfile-nginx from the root directory
                        sh 'docker build -t nginx-bop:latest -f Dockerfile-nginx .'

                        // Tag the image with ECR repository URL
                        sh 'docker tag nginx-bop:latest $ECR_NGINX_REPO:latest'

                        // Push the image to ECR
                        sh 'docker push $ECR_NGINX_REPO:latest'
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    // Apply the application deployment and service files
                    sh 'kubectl apply -f $WORKSPACE/EKS-resources/statuspage-deployment.yaml'
                    sh 'kubectl apply -f $WORKSPACE/EKS-resources/statuspage-service.yaml'
                }
            }
        }

        stage('Deploy Nginx') {
            steps {
                script {
                    // Apply the Nginx deployment and service files
                    sh 'kubectl apply -f $WORKSPACE/EKS-resources/nginx-deployment.yaml'
                    sh 'kubectl apply -f $WORKSPACE/EKS-resources/nginx-service.yaml'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
