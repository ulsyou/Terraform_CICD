pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = 'test'
        AWS_SECRET_ACCESS_KEY = 'test'
        AWS_DEFAULT_REGION = 'us-east-1'
        DOCKER_IMAGE_NAME = 'my-localstack-nginx'
        PATH = "$HOME/.local/bin:$PATH" // Cập nhật PATH để tìm AWS CLI
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/ulsyou/Terraform_CICD'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE_NAME}")
                }
            }
        }
        stage('Run LocalStack Container') {
            steps {
                script {
                    sh "docker stop ${DOCKER_IMAGE_NAME} || true"
                    sh "docker rm ${DOCKER_IMAGE_NAME} || true"
                    sh "docker run -d --name ${DOCKER_IMAGE_NAME} -p 80:80 -p 4566:4566 ${DOCKER_IMAGE_NAME}"
                    sh "sleep 30"
                }
            }
        }
        stage('Setup AWS CLI') {
            steps {
                sh '''
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip -o awscliv2.zip
                    ./aws/install -i $HOME/.local/aws-cli -b $HOME/.local/bin
                    export PATH=$HOME/.local/bin:$PATH
                    aws --version
                '''
            }
        }
        stage('Check AWS CLI') {
            steps {
                sh 'echo $PATH'
                sh 'which aws || echo "AWS CLI not found"'
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
        stage('Deploy Web') {
            steps {
                script {
                    def instanceIp = sh(script: """
                        aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
                        --filters 'Name=tag:Name,Values=web-instance' \
                        --query 'Reservations[].Instances[].PrivateIpAddress' \
                        --output text
                    """, returnStdout: true).trim()
                    echo "Instance IP: ${instanceIp}"
                    sh "docker cp index.html ${DOCKER_IMAGE_NAME}:/var/www/html/"
                }
            }
        }
        stage('Test Deployment') {
            steps {
                script {
                    def containerIp = sh(script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DOCKER_IMAGE_NAME}", returnStdout: true).trim()
                    def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://${containerIp}", returnStdout: true).trim()
                    if (response == "200") {
                        echo "Deployment successful! Website is accessible at http://${containerIp}"
                    } else {
                        error "Deployment failed. HTTP status code: ${response}"
                    }
                }
            }
        }
    }
    post {
        always {
            sh "docker stop ${DOCKER_IMAGE_NAME} || true"
            sh "docker rm ${DOCKER_IMAGE_NAME} || true"
        }
    }
}
