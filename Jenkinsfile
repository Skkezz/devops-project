pipeline {
    agent none

    stages {
        stage('Checkout') {
            agent { label 'default-jenkins-agent' }
            steps {
                checkout scm
            }
        }

        stage('Build docker image') {
            agent { label 'my-basic-agent' }
            steps {
		sh '''
		pwd
		ls
		echo "Bulding docker image..."
		docker build -t my-basic-app .
		pwd
		ls
		'''
		
            }
        }

        stage('Run terraform') {
            agent { label 'my-basic-agent' }
            steps {
                echo 'Running Terraform...'
                sh '''
                cd terraform
                terraform init
                terraform apply -auto-approve
                '''
            }
        }

        stage('Deploy') {
            agent { label 'my-basic-agent' }
            steps {
                script {
                    def EC2_IP = sh(
                        script: 'terraform output -raw ec2_ip',
                        returnStdout: true
                    ).trim()

                    sh """
                    scp -i terraform/my-basic-private-key terraform/test.txt ec2-user@${EC2_IP}:/home/ec2-user/
                    """
                }
            }
        }
    }
}
