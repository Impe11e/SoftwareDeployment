FROM node:18-slim

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY mywebapp/ ./mywebapp/

RUN mkdir -p /etc/mywebapp

EXPOSE 3000

CMD ["node", "mywebapp/src/app.js"]