pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = 'test'
        AWS_SECRET_ACCESS_KEY = 'test'
        AWS_DEFAULT_REGION = 'us-east-1'
        PATH = "$HOME/.local/bin:$PATH" 
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/ulsyou/Terraform_CICD'
            }
        }
        stage('Run LocalStack') {
            steps {
                script {
                    sh "docker-compose up -d"
                    sh "sleep 30"
                }
            }
        }
        stage('Setup AWS CLI') {
            steps {
                sh '''
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip -o awscliv2.zip
                    ./aws/install -i /var/lib/jenkins/.local/aws-cli -b /var/lib/jenkins/.local/bin --update
                    export PATH=/var/lib/jenkins/.local/bin:$PATH
                    aws --version
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
        stage('Deploy Web') {
            steps {
                script {
                    def cloudfrontUrl = sh(script: "tflocal output -raw cloudfront_url", returnStdout: true).trim()
                    echo "Website deployed. You can access it at http://${cloudfrontUrl}"
                }
            }
        }
    }
    post {
        always {
            sh "docker-compose down || true"
        }
    }
}
