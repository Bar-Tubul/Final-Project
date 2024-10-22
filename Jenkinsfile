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
        AWS_REGION = 'us-east-1'
        ECR_APP_REPO = '992382545251.dkr.ecr.us-east-1.amazonaws.com/statuspage-bop'
        ECR_NGINX_REPO = '992382545251.dkr.ecr.us-east-1.amazonaws.com/nginx-bop'
        AWS_CREDENTIALS_ID = 'aws-jenkins-creds'
    }

    stages {
        stage('Build Application Image') {
            steps {
                container('kaniko') {
                    script {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                            // Build the application image using Kaniko
                            sh 'executor --context $WORKSPACE --dockerfile $WORKSPACE/statuspage/Dockerfile --destination $ECR_APP_REPO:LTS'
                        }
                    }
                }
            }
        }

        stage('Build Nginx Image') {
            steps {
                container('kaniko') {
                    script {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                            // Build the Nginx image using Kaniko
                            sh 'executor --context $WORKSPACE --dockerfile $WORKSPACE/Dockerfile-nginx --destination $ECR_NGINX_REPO:LTS'
                        }
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
