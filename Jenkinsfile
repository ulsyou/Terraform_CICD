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
        
        stage('Build Docker Image') {
            steps {
                script {
             
                    docker.build('my-web-server')
                }
            }
        }

        stage('Test Docker Container') {
            steps {
                script {
                  
                    def app = docker.image('my-web-server')
                    app.inside {
                        sh 'curl http://localhost'
                    }
                }
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
                
                    def instanceIp = '10.153.21.207'
        
                    sh "docker cp index.html ${instanceIp}:/var/www/html/"
                }
            }
        }
    }
}
