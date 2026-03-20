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

               archiveArtifacts artifacts: 'terraform/my-basic-private-key', fingerprint: true
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
                    
                    // SCP fajl na EC2
                    // 2. SCP fajl
                    sh "chmod 400 terraform/my-basic-private-key"
                    sh "scp -r -o StrictHostKeyChecking=no -i terraform/my-basic-private-key app/ ${ssh_user}@${ec2_ip}:/home/${ssh_user}/"
                    

                    // ssh na instancu i docker, iako imam app file, image vucem preko docker hub-a.
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i terraform/my-basic-private-key ${ssh_user}@${ec2_ip}"
                        docker pull matija24/my-basic-server:latest &&
                        docker images &&
                        docker run -d --name my-basic-app -p 5000:5000 matija24/my-basic-server:latest &&
                        docker ps -a 
                        "
                    '''
                    
                   


                    

                }
          }
        }
        
           
          
                
            
        
    }
}
