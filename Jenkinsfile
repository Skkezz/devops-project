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
		echo "Bulding docker image..."
		docker build -t my-basic-app .
		'''
		
            }
        }

	stage('Run terraform + Deploy') {
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
                   terraform apply -auto-approve
                   '''
               }
               script {
                        // 1. Terraform outputs u Groovy promenljive
                    def ec2_ip = sh(
                        script: "cd terraform && terraform output -raw ec2_public_ip",
                        returnStdout: true
                    ).trim()

                    def ssh_user = sh(
                        script: "cd terraform && terraform output -raw ssh_user",
                        returnStdout: true
                    ).trim()
                    
                    
                    echo "EC2_IP: ${ec2_ip}"
                    echo "SSH_USER: ${ssh_user}"
                    echo "SSH_USER: "
                    // SCP fajl na EC2
                    // 2. SCP fajl
                    
                    sh "scp -o StrictHostKeyChecking=no -i terraform/my-basic-private-key app/app.py ${ssh_user}@${ec2_ip}:/home/${ssh_user}/"
                }
          }
        }
        
           
          
                
            
        
    }
}
