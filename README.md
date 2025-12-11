docker build -t gestion-app .

docker run -d \
  -p 8080:8080 \
  -e PORT=8080 \
  -e DB_HOST=my-sdp-rds-mysql.c5802u6sqo13.us-east-1.rds.amazonaws.com \
  -e DB_USER=admin \
  -e DB_PASSWORD=labpassword123 \
  -e DB_NAME=gestion_app \
  --name gestion-app \
  gestion-app
