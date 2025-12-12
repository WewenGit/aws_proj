# Étapes à respecter pour l'installation de l'infrastructure sur AWS

### Premièrement sur Cloud9

```
https://github.com/WewenGit/aws_proj.git
cd aws_proj/infra
wget https://releases.hashicorp.com/terraform/1.13.4/terraform_1.13.4_linux_amd64.zip
unzip terraform_1.13.4_linux_amd64.zip
sudo mv terraform /usr/local/bin
terraform init
terraform apply
```

#Entrez yes si demandé

### Se connecter sur l'EC2 vcp1-ec2 puis entrer :


```
sudo yum update -y
sudo yum install -y docker
sudo yum install -y git
sudo service docker start
sudo dnf update -y
sudo dnf install mariadb105-server
```
#Entrer y si demandé


### Votre instance RDS est générée, vous pouvez récupérer son point de terminaison dans l'onglet Connectivité et sécurité de l'outil RDS d'AWS sous la forme "vpc1-rds.c3wgqeo2m8hp.us-east-1.rds.amazonaws.com"

#Optionnel (pour tester la co à la base)
```
mysql -h <RDS_ENDPOINT> -P 3306 -u admin -p
```
Le MDP (modifiable depuis le fichier situé dans /infra/modules/vpc/main.tf) est cloudproj123

### Puis
```
git clone https://github.com/WewenGit/aws_proj.git
cd aws_proj/appli-web
sudo docker build -t gestion-app .
sudo docker run -d \
-p 8080:8080 \
-e PORT=8080 \
-e DB_HOST=vpc1-rds.c3wgqeo2m8hp.us-east-1.rds.amazonaws.com\
-e DB_USER=admin \
-e DB_PASSWORD=projcloud123 \
-e DB_NAME=gestion_app \
--name gestion-app \
gestion-app
```
