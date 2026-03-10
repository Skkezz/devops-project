pipeline {
    agent {
        node {
            label 'my-basic-agent'
        }
    }
    triggers {
        pollSCM '* * * * *'
    }
    stages {
        stage('Pulling git repo') {
             {
                echo 'Pulling git repo...'
                sh '''
                git pull https://github.com/Skkezz/devops-project
                git status
                '''
             }
        }
        stage('Build docker image')
            {
               echo 'Building...'
               sh '''
                docker build -t my-basic-app .
               '''
            }

        stage('Run terrafrom') {
            echo 'Starting terraform...'
            sh '''
            cd /terraform/provider.tf
            terraform init
            cd ..
            terraform apply -auto-approve
            sudo chmod 400 my-basic-private-key
            '''
            steps {
                script {
                    def EC2_IP = sh(
                        script: 'terraform output -raw ec2_ip',
                        returnStdout: true
                    ).trim()
                }
            }
        }
        stage('Deploying app and connecting to instance') {
            echo'Deploying...'
             sh '''
                scp -i my-basic-private-key test.txt ec2-user@${EC2_IP}:/home/ec2-user/
                ssh -i my-basic-private-key ec2-user@${EC2_IP}
                '''
        }
        stage('Test') {
            steps {
                echo 'Testing...'
                sh '''
                echo 'Running docker image"
                cat test.txt
                docker run -d --name my-basic-server -p3000:5000 my-basic-app
                docker ps -a
                '''
            }
        }
    }
}
