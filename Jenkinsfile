pipeline {
    agent {
        node {
            label 'default-jenkins-agent'
        }
    }

    triggers {
        pollSCM '* * * * *'
    }

    stages {
        stage('Pulling git repo') {
            steps {
                echo 'Pulling git repo...'
                sh '''
                    git pull https://github.com/Skkezz/devops-project
                    git status
                '''
            }
        }

        stage('Build docker image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    docker build -t my-basic-app .
                '''
            }
        }

        stage('Run terraform') {
            agent {
                label 'my-basic-agent'
            }
            steps {
                echo 'Starting Terraform...'
                sh '''
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                    chmod 400 my-basic-private-key
                '''
                    script {
                        // Uzmi EC2 IP iz Terraform output
                        env.EC2_IP = sh(
                            script: 'terraform output -raw ec2_ip',
                            returnStdout: true
                        ).trim()
                    }
                }
        }

        stage('Deploy app to EC2') {
            steps {
                echo 'Deploying app...'
                script {
                    sh """
                        scp -i terraform/my-basic-private-key test.txt ec2-user@${env.EC2_IP}:/home/ec2-user/
                        ssh -i terraform/my-basic-private-key ec2-user@${env.EC2_IP} 'echo Connected to EC2!'
                    """
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Testing...'
                sh '''
                    echo 'Running docker image'
                    cat test.txt
                    docker run -d --name my-basic-server -p 3000:5000 my-basic-app
                    docker ps -a
                '''
            }
        }
    }
}
