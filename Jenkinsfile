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

               withCredentials([usernamePassword(
                   credentialsId: 'aws-creds',
                   usernameVariable: 'AWS_ACCESS_KEY_ID',
                   passwordVariable: 'AWS_SECRET_ACCESS_KEY'
               )]) {

                   sh '''
                   cd terraform
                   terraform init
                   terraform destroy -auto-approve || true
                   terraform apply -auto-approve
                   '''
               }
          }
        }
        stage('Deploy') {
            agent { label 'my-basic-agent' }
            steps {
                script {
                        // 1. Terraform outputs u Groovy promenljive
                    sh 'cd terraform'
                    
                    def ec2_ip = sh 'terraform output ec2_public_ip'
                    def ssh_user = sh 'terraform output ssh_user'

                    sh 'terraform refresh'
                    echo "EC2_IP: ${ec2_ip}"
                    echo "SSH_USER: ${ssh_user}"

                    // SCP fajl na EC2
                    // 2. SCP fajl
                    sh "scp -o StrictHostKeyChecking=no -i terraform/my-basic-private-key app/app.py ${ssh_user}@${ec2_ip}:/home/${ssh_user}/"
        }
    }
}
    }
}
