pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_APP_REPO = '992382545251.dkr.ecr.us-east-1.amazonaws.com/statuspage-bop'
        ECR_NGINX_REPO = '992382545251.dkr.ecr.us-east-1.amazonaws.com/nginx-bop'
        AWS_CREDENTIALS_ID = 'aws-jenkins-creds'
        IMAGE_TAG = "${env.BUILD_ID}" // Unique identifier for each build
    }

    stages {
        stage('Build Application Image') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        // Login to ECR
                        sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_APP_REPO'

                        // Build the application Docker image
                        sh 'docker build -t statuspage-app:$IMAGE_TAG ./statuspage'

                        // Tag the image with the latest tag
                        sh 'docker tag statuspage-app:$IMAGE_TAG $ECR_APP_REPO:latest'

                        // Tag the image with the unique image tag
                        sh 'docker tag statuspage-app:$IMAGE_TAG $ECR_APP_REPO:$IMAGE_TAG'

                        // Push both images to ECR
                        sh 'docker push $ECR_APP_REPO:latest'
                        sh 'docker push $ECR_APP_REPO:$IMAGE_TAG'
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
                        sh 'docker build -t nginx-bop:$IMAGE_TAG -f Dockerfile-nginx .'

                        // Tag the image with the latest tag
                        sh 'docker tag nginx-bop:$IMAGE_TAG $ECR_NGINX_REPO:latest'

                        // Tag the image with the unique image tag
                        sh 'docker tag nginx-bop:$IMAGE_TAG $ECR_NGINX_REPO:$IMAGE_TAG'

                        // Push both images to ECR
                        sh 'docker push $ECR_NGINX_REPO:latest'
                        sh 'docker push $ECR_NGINX_REPO:$IMAGE_TAG'
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
                        sh "kubectl set image deployment/statuspage-deployment statuspage-app=$ECR_APP_REPO:latest" // Use the latest tag for deployment
                        sh 'kubectl apply -f $WORKSPACE/EKS-resources/statuspage-service.yaml'
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
                        sh "kubectl set image deployment/nginx-deployment nginx-bop=$ECR_NGINX_REPO:latest" // Use the latest tag for deployment
                        sh 'kubectl apply -f $WORKSPACE/EKS-resources/nginx-service.yaml'
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
