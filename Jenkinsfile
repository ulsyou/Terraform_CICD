pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = 'test'
        AWS_SECRET_ACCESS_KEY = 'test'
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/ulsyou/Terraform_CICD' 
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
                sh 'tflocal apply -input=false tfplan'
            }
        }

        stage('Deploy Web') {
            steps {
                script {
                    def instanceIp = sh(script: "tflocal output -raw public_ip", returnStdout: true).trim()
                    sh "scp -o StrictHostKeyChecking=no -i /path/to/your/key.pem index.html ubuntu@${instanceIp}:/var/www/html/"
                }
            }
        }
    }
}
