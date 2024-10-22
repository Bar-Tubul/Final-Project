pipeline {
    agent {
        kubernetes {
            label 'jenkins'
            defaultContainer 'jnlp'
            yaml """
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: kaniko
                image: gcr.io/kaniko-project/executor:latest
                command: ["sleep"]
                args: ["infinity"]
            """
        }
    }

    environment {
        AWS_REGION = 'your-aws-region'
        ECR_APP_REPO = 'your-application-ecr-repo-uri'
        ECR_NGINX_REPO = 'your-nginx-ecr-repo-uri'
        AWS_CREDENTIALS_ID = 'your-aws-credentials-id'
    }

    stages {
        stage('Build Application Image') {
            steps {
                container('kaniko') {
                    script {
                        // Login to ECR
                        sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_APP_REPO'
                        // Build the application image using Kaniko
                        sh 'executor --context $WORKSPACE --dockerfile $WORKSPACE/statuspage/Dockerfile --destination $ECR_APP_REPO:LTS'
                    }
                }
            }
        }

        stage('Build Nginx Image') {
            steps {
                container('kaniko') {
                    script {
                        // Login to ECR
                        sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_NGINX_REPO'
                        // Build the Nginx image using Kaniko
                        sh 'executor --context $WORKSPACE --dockerfile $WORKSPACE/Dockerfile-nginx --destination $ECR_NGINX_REPO:LTS'
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    // Apply the application deployment and service files
                    sh 'kubectl apply -f $WORKSPACE/EKS-resources/deployment_app.yml'
                    sh 'kubectl apply -f $WORKSPACE/EKS-resources/service_app.yml'
                }
            }
        }

        stage('Deploy Nginx') {
            steps {
                script {
                    // Apply the Nginx deployment and service files
                    sh 'kubectl apply -f $WORKSPACE/EKS-resources/deployment_nginx.yml'
                    sh 'kubectl apply -f $WORKSPACE/EKS-resources/service_nginx.yml'
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
