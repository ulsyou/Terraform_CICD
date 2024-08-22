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
        stage('Parallel Execution') {
            parallel {
                stage('Checkout') {
                    steps {
                        git 'https://github.com/ulsyou/Terraform_CICD'
                    }
                }
                stage('Install Dependencies') {
                    steps {
                        sh '''
                            if ! command -v pip &> /dev/null
                            then
                                apt-get update && apt-get install -y python3-pip
                            fi

                            if ! command -v tflocal &> /dev/null
                            then
                                pip install terraform-local
                            fi

                            if ! command -v aws &> /dev/null
                            then
                                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                                unzip -o awscliv2.zip
                                ./aws/install -i /var/lib/jenkins/.local/aws-cli -b /var/lib/jenkins/.local/bin --update
                            fi

                            aws --version
                        '''
                    }
                }
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
        stage('Deploy') {
            steps {
                script {
                    sh '''
                        aws --endpoint-url=http://localhost:4566 s3 rb s3://my-website-bucket --force || true
        
                        aws --endpoint-url=http://localhost:4566 s3 mb s3://my-website-bucket
        
                        aws --endpoint-url=http://localhost:4566 s3 cp index.html s3://my-website-bucket/index.html
                    '''
                    echo 'Website deployed to S3 at URL: http://localhost:4566/my-website-bucket/index.html'
                }
            }
        }
    }
    post {
        always {
            sh "docker-compose -f docker-compose.yml down"
        }
    }
}
