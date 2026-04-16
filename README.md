<h1> Cloud-Based DevOps CI/CD Pipeline Project </h1>
 
<h2> Deploying basic flask server in a private subnet using SSL and HTTPS encryption with free DNS using Jenkins, GitHub, Terraform, Docker, and AWS. </h2> 

This project is made as an example for automated creation (and destruction) of AWS resources and private EC2 in which the docker image resides for deploying flask server.

For fulfillment of this task you have to these next steps:

* Request a free domain ("devopsproject.eu.org") from EU.ORG and where you connect it to the Hostry servers. Waiting for domain may take some time (24 hours or more), so it's best to do this first!
    * Link for DNS query: https://nic.eu.org/
    * Link for free DNS: https://hostry.com/products/dns/ 
    * Link for video tutorial: https://www.youtube.com/watch?v=mYvVQkbyNRg
. 
* In AWS Certificate Manager requeset certificate where you can find CNAME name and CNAME value for configuration of free DNS Hostry.

    * After successfully configuring certificate his status should be ✅Issued! With this we can use SSL for private EC2 in which will reside flask server.

* Install <bold>Docker</bold> localy.

* Creating Jenkins image and starting its container localy. After that install suggested plugins and additional plugins: Docker and AWS creds.

    * Inside docker plugin set Docker Host URI: unix:///var/run/docker.sock and enabled it (check for connection). For docker agent label and name are "my-basic-agent", and docker image that are we using for this agent is: "matija24/my-basic-agent:latest". Other settings as desired.

    * Inside of AWS creds plugin put credentials of IAM user that you are using.


* To create a deploy pipeline you need to bind pipeline job with "Jenkinsfile.deploy" script that is located inside of this github repo. The same applies for the destroy pipeline using "Jenkinsfile.destroy" script. Also, pipeline for destroying has double checking inside the jenkins console!

* You need to set up inside IAM console for IAM user and S3 bucket certain privileges, same goes for roles that are assigned to the public and private EC2.

<div align="center">
  <img src="https://github.com/Skkezz/devops-project/blob/main/screenshots/pipeline.png" alt="CI/CD pipeline" width="400"/>
</div>

After starting the pipeline and successfully creating the AWS architecture using resources in terraform, the following architecture is obtained.

<div align="center">
    <img src="https://github.com/Skkezz/devops-project/blob/main/screenshots/aws_architecture.png" alt="AWS architecture" width="400">    
</div>

* Since Application Load Balancer (ALB) is used for safe and more efficient network traffic, where you also get a domain name from AWS, we must also set that domain name to the DNS Hostry configuration. That's how we secure the server with HTTPS protocol. ALB domain name will print out in terminal after successfully deploying.

<div align="center">
    <img src="https://github.com/Skkezz/devops-project/blob/main/screenshots/app_gui.png" alt="app gui" width="400">
</div>

<h3>Why was this project made?</h3>

 This project was created during the duration of the AWS free trial and primarily serves for learning and improving DevOps tools. The project was created to use a free domain and hosting services, but to be a realistic company project with costs like ALB.