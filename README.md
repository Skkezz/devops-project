# Cloud-Based DevOps CI/CD Pipeline Project
 
## Deploying basic flask server in a private subnet using SSL and HTTPS encryption with free DNS using Jenkins, GitHub, Terraform, Docker, and AWS. 


Ovaj projekat je napravljen kao primer za automatizovano kreiranje (i destrukciju) AWS resursa i privatne EC2 instance u kojoj se nalazi docker image sa pokretanje flask servera.

Za ispunjenje ovog zadatka treba da se urade sledece stavke:

* Zahtevanje free domain ("devopsproject.eu.org") od EU.ORG i konektujemo ga na Hostry servere. Domain moze da se ceka i do nekoliko dana zato je najbolje ovo da resimo odmah!
    Link za zahtevanje domain-a: https://nic.eu.org/
    Link za besplatan DNS: https://hostry.com/products/dns/ 
    Link za video tutorial: https://www.youtube.com/watch?v=mYvVQkbyNRg

* U AWS Ceritficate Manager zatraziti certifikat u kome se nalaze CNAME name i CNAME value za konfiguraciju Free DNS Hostry. 

    Primer: Posto je meni domain ime "devopsproject.eu.org" iz certifikata CNAME name  uzimam sve karaktere (samo ne "." karakter) pre domain imena i postavljam unutar dns konfiguracije za subdomain. Za CNAME value uzimam sve karaktere (samo ne zadnji "." karakter) i  postavljam unutar dns konfiguracije za value. Vrednosti unutar free dns hostry konfiguracije se postavljaju na tip CNAME.

    Nakon uspesne konfiguracije u AWS Certificate Manager pisati za status certifikata da je ✅Issued! Sa ovim smo obezbedili koriscenje SSL-a za privatnu instancu u kojoj ce da se nalazi flask server.

* Instalacija docker-a na lokalnoj masini.

* Kreiranje Jenkins image-a i pokretanje kontenjera na lokalnoj masini (kod mene je port 8080). U URL pretrazivaca kucati "localhost:port_broj" i instalirati predlozene pluginove. Nakon toga instalirati dodatne pluginove: Docker i AWS creds.

    * Unutar docker plugina za Docker Host URI: unix:///var/run/docker.sock i cekirati enabled (proveriti konekciju). Za Docker agenta label i ime su "my-basic-agent" i koriste docker image: "matija24/my-basic-agent:latest" (public docker hub), ostale opcije po zelji.

    * Unutar AWS creds-a staviti kredencijale IAM korisnika koje koristite.

* Za pravljenje deploy pipeline-a treba se povezati pipeline job sa github repozitorijum u kojoj je Jenkinsfile.deploy skripta. Isto i za destroy pipeline koristeci Jenkinsfile.destroy skriptu. Kod destroy pipeline-a postoji double check koji mora da se potvrdi kako bi se izvrsio.

<div align="center">
  <img src="https://github.com/Skkezz/devops-project/blob/main/screenshots/pipeline.png" alt="CI/CD pipeline" width="400"/>
</div>

