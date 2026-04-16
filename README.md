<h1> Cloud-Based DevOps CI/CD Pipeline Project </h1>
 
<h2> Deploying basic flask server in a private subnet using SSL and HTTPS encryption with free DNS using Jenkins, GitHub, Terraform, Docker, and AWS. </h2> 

Ovaj projekat je napravljen kao primer za automatizovano kreiranje (i destrukciju) AWS resursa i privatne EC2 instance u kojoj se nalazi docker image za pokretanje flask servera.

Za ispunjenje ovog zadatka treba da se urade sledece stavke:

* Zahtevanje free domain ("devopsproject.eu.org") od EU.ORG i konektujemo ga na Hostry servere. Domain moze da se ceka i do nekoliko dana zato je najbolje ovo da resimo odmah!
    * Link za zahtevanje domain-a: https://nic.eu.org/
    * Link za besplatan DNS: https://hostry.com/products/dns/ 
    * Link za video tutorial: https://www.youtube.com/watch?v=mYvVQkbyNRg

* U AWS Ceritficate Manager zatraziti certifikat u kome se nalaze CNAME name i CNAME value za konfiguraciju Free DNS Hostry. 

    * Primer: Posto je meni domain ime "devopsproject.eu.org" iz certifikata CNAME name  uzimam sve karaktere (samo ne "." karakter) pre domain imena i postavljam unutar dns konfiguracije za subdomain. Za CNAME value uzimam sve karaktere (samo ne zadnji "." karakter) i  postavljam unutar dns konfiguracije za value. Vrednosti unutar free dns hostry konfiguracije se postavljaju na tip CNAME.

    Nakon uspesne konfiguracije u <bold>AWS Certificate Manager</bold> pisati za status certifikata da je ✅Issued! Sa ovim smo obezbedili koriscenje SSL-a za privatnu instancu u kojoj ce da se nalazi flask server.

* Instalacija <bold>Docker-a</bold> na lokalnoj masini.

* Kreiranje <bold>Jenkins</bold> image-a i pokretanje kontenjera na lokalnoj masini (kod mene je port 8080). U URL pretrazivaca kucati "localhost:port_broj" i instalirati predlozene pluginove. Nakon toga instalirati dodatne pluginove: Docker i AWS creds.

    * Unutar docker plugina za Docker Host URI: unix:///var/run/docker.sock i cekirati enabled (proveriti konekciju). Za Docker agenta label i ime su "my-basic-agent" i koriste docker image: "matija24/my-basic-agent:latest" (public docker hub), ostale opcije po zelji.

    * Unutar AWS creds-a staviti kredencijale IAM korisnika kojeg koristite.

* Za pravljenje deploy pipeline-a treba se povezati pipeline job sa github repozitorijum u kojoj je Jenkinsfile.deploy skripta. Isto i za destroy pipeline koristeci Jenkinsfile.destroy skriptu. Kod destroy pipeline-a postoji double check koji mora da se potvrdi kako bi se izvrsio!

* Treba postaviti unutar aws iam console za iam korisnika odgovarajuca pravila, tako i za role-ove za koje ce da koristi privatna i javna ec2 instanca.

<div align="center">
  <img src="https://github.com/Skkezz/devops-project/blob/main/screenshots/pipeline.png" alt="CI/CD pipeline" width="400"/>
</div>

Nakon pokretanja pipeline-a i uspesnog kreiranja AWS arhitekture koristeci resurse u terraformu dobija se sledeca arhitektura.

<div align="center">
    <img src="https://github.com/Skkezz/devops-project/blob/main/screenshots/aws_architecture.png" alt="AWS architecture" width="400">    
</div>

* Posto se koristi Application Load Balancer za sigurni i efikasniji mrezni saobracaj, gde takodje se dobija njegov domain name koji pruza aws, taj domain name moramo isto da dodamo u konfiguraciju dns-a hostry-a. Tako osiguravamo flask web server sa HTTPS protokolom. ALB domain name ce se prikazati u output terminala kad se izvrsi pipeline.

<div align="center">
    <img src="https://github.com/Skkezz/devops-project/blob/main/screenshots/app_gui.png" alt="app gui" width="400">
</div>

<h3>Zasto je ovaj projekat napravljen?</h3>

 Ovaj projekat je napravljen za vreme trajanja AWS free trial-a i prvenstvo sluzi za ucenje i usavrsavanje DevOps alata. Projekat je pravljen tako da se koristi besplatan domen i hosting usluge ali da bude realan firmin projekat sa troskovima poput alb-a.