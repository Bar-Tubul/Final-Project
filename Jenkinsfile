pipeline {
    agent any // Run on any available agent

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
                        // Run Kaniko inside a Docker container
                        sh """
                        docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v \$WORKSPACE:/workspace \
                        gcr.io/kaniko-project/executor:latest \
                        --context=/workspace \
                        --dockerfile=/workspace/statuspage/Dockerfile \
                        --destination=$ECR_APP_REPO:LTS
                        """
                    }
                }
            }
        }

        stage('Build Nginx Image') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        // Run Kaniko inside a Docker container for Nginx
                        sh """
                        docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v \$WORKSPACE:/workspace \
                        gcr.io/kaniko-project/executor:latest \
                        --context=/workspace \
                        --dockerfile=/workspace/Dockerfile-nginx \
                        --destination=$ECR_NGINX_REPO:LTS
                        """
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
