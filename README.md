# Étapes à respecter pour l'installation de l'infrastructure sur AWS

### Premièrement sur Cloud9

```
https://github.com/WewenGit/aws_proj.git
cd aws_proj
wget https://releases.hashicorp.com/terraform/1.13.4/terraform_1.13.4_linux_amd64.zip
unzip terraform_1.13.4_linux_amd64.zip
sudo mv terraform /usr/local/bin
terraform init
terraform apply
```

#Entrez yes si demandé

### Se connecter sur l'EC2 VCP-1 puis entrer :


```
sudo yum update -y
sudo yum install -y docker
sudo yum install -y git
sudo service docker start
sudo dnf update -y
sudo dnf install mariadb105-server
```


#Optionnel (pour tester la co à la base)
```
mysql -h <RDS_ENDPOINT> -P 3306 -u admin -p
```

#Puis
```
git clone https://github.com/WewenGit/aws_proj.git
cd aws_proj/appli-web
docker build -t gestion-app .
docker run -d \
-p 8080:8080 \
-e PORT=8080 \
-e DB_HOST=vpc1-rds.c3wgqeo2m8hp.us-east-1.rds.amazonaws.com\
-e DB_USER=admin \
-e DB_PASSWORD=projcloud123 \
-e DB_NAME=gestion_app \
--name gestion-app \
gestion-app
```
