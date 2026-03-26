pipeline {
    agent none

    stages {
        stage('Checkout') {
            agent any
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
                withAWS(credentials: 'aws-creds', region: 'eu-central-1') {
                   sh '''
                   aws ec2 delete-key-pair --key-name my-basic-private-key || echo "Key does not exist."
                   rm -f terraform/my-basic-private-key
                   '''

                   echo "Running terraform..."

                    withEnv([
                        "AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID}",
                        "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}",
                        "AWS_DEFAULT_REGION=eu-central-1"
                    ]) {
            
                        sh '''
                        cd terraform
                        terraform init
                        terraform apply -auto-approve -no-color
                        '''
                    }
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
                        
                        
                        echo "IP address of EC2: ${ec2_ip}"
                        echo "User for EC2: ${ssh_user}"
                
                        sh "chmod 400 terraform/my-basic-private-key"
                        sh "scp -r -o StrictHostKeyChecking=no -i terraform/my-basic-private-key app/ ${ssh_user}@${ec2_ip}:/home/${ssh_user}/"
                        

                        // ssh na instancu i docker, iako imam app file, image vucem preko docker hub-a.
                        sh '''
                        echo "Waiting for EC2 to be ready..."
                        sleep 25
                        '''
                        sh """
                        ssh -o StrictHostKeyChecking=no -i terraform/my-basic-private-key ${ssh_user}@${ec2_ip} "
                        which docker || echo 'Docker not installed' ;
                        docker pull matija24/my-basic-server:latest &&
                        docker images &&
                        docker run -d --name my-basic-app -p 5000:5000 matija24/my-basic-server:latest &&
                        docker ps -a 
                        "
                        """
                        
                    


                        

                    }
            }
            }
        
           
          
                
            
        
    }
}
