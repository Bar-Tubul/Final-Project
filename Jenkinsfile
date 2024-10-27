pipeline {
    agent { label 'agent1' }
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

                        // Push the image to ECR (this will overwrite the existing latest image)
                        sh 'docker tag statuspage-app:latest $ECR_APP_REPO:latest'
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
                        sh 'docker build --no-cache -t nginx-bop:latest -f Dockerfile-nginx .'

                        // Push the image to ECR (this will overwrite the existing latest image)
                        sh 'docker tag nginx-bop:latest $ECR_NGINX_REPO:latest'
                        sh 'docker push $ECR_NGINX_REPO:latest'
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        // Apply the application deployment and service files
                        sh 'aws eks --region $AWS_REGION update-kubeconfig --name bop-eks-cluster'
                        sh "kubectl set image deployment/statuspage statuspage=$ECR_APP_REPO:latest" // Use the latest tag for deployment
                        sh "kubectl rollout restart deployment/statuspage"
                        sh 'kubectl apply -f EKS-resources/statuspage-deployment.yaml'  // Apply deployment configuration
                        sh 'kubectl apply -f EKS-resources/statuspage-service.yaml'     // Apply service configuration
                    }
                }
            }
        }

        stage('Deploy Nginx') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        // Apply the Nginx deployment and service files
                        sh 'aws eks --region $AWS_REGION update-kubeconfig --name bop-eks-cluster'
                        sh "kubectl set image deployment/nginx nginx=$ECR_NGINX_REPO:latest" // Use the latest tag for deployment
                        sh "kubectl rollout restart deployment/nginx"
                        sh 'kubectl apply -f EKS-resources/nginx-deployment.yaml'  // Apply deployment configuration
                        sh 'kubectl apply -f EKS-resources/nginx-service.yaml'     // Apply service configuration
                    }
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
