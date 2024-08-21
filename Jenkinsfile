pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = 'test'
        AWS_SECRET_ACCESS_KEY = 'test'
        AWS_DEFAULT_REGION = 'us-east-1'
        DOCKER_IMAGE_NAME = 'my-localstack-container'
        PATH = "$HOME/.local/bin:$PATH" 
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/ulsyou/Terraform_CICD'
            }
        }
        stage('Install tflocal and AWS CLI') {
            steps {
                sh '''
                    if ! command -v pip &> /dev/null
                    then
                        apt-get update && apt-get install -y python3-pip
                    fi

                    pip install terraform-local awscli

                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip -o awscliv2.zip
                    ./aws/install -i /var/lib/jenkins/.local/aws-cli -b /var/lib/jenkins/.local/bin --update

                    aws --version
                '''
            }
        }
        stage('Start LocalStack') {
            steps {
                sh '''
                    docker-compose -f docker-compose.yml up -d
                '''
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'tflocal init'
            }
        }
        stage('Terraform Plan') {
            steps {
                sh 'tflocal plan -out=tfplan'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'tflocal apply -auto-approve tfplan'
            }
        }
        stage('Deploy to S3 via LocalStack') {
            steps {
                script {
                    sh '''
                        echo "Hello from LocalStack S3 Bucket" > index.html
                        aws --endpoint-url=http://localhost:4566 s3 mb s3://my-website-bucket
                        aws --endpoint-url=http://localhost:4566 s3 cp index.html s3://my-website-bucket/index.html
                    '''
                    
                    echo "Website deployed to S3. Access it via CloudFront or S3 URL"
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
