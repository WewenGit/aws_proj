# Image Node.js
FROM node:20-alpine

WORKDIR /usr/src/app

# Installation des dépendances
COPY package*.json ./
RUN npm install --only=production

# Copie du code
COPY . .

# Le service écoute sur 8080
EXPOSE 8080

# Commande de démarrage
CMD ["npm", "start"]
