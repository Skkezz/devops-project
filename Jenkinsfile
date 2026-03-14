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
    node('my-basic-agent') {
        checkout scm

        script {
            // Dobijamo Terraform output i čuvamo ga u promenljivu
            env.EC2_IP = sh(
                script: "cd terraform && terraform output -raw ec2_public_ip",
                returnStdout: true
            ).trim()

            env.SSH_USER = sh(
                script: "cd terraform && terraform output -raw shh_user",
                returnStdout: true
            ).trim()

            // SCP fajl na EC2
            sh """
            scp -o StrictHostKeyChecking=no -i terraform/my-basic-private-key \
            test.txt $SSH_USER@$EC2_IP:/home/$SSH_USER/
            """
        }
    }
}
    }
}
