FROM node:18-slim

WORKDIR /app

COPY package*.json ./

RUN npm install --production

COPY mywebapp/ ./mywebapp/

RUN mkdir -p /etc/mywebapp && \
    echo '{"server":{"host":"0.0.0.0","port":3000},"db":{"user":"app","host":"db","database":"mywebapp_db","password":"password","port":5432}}' > /etc/mywebapp/config.json

EXPOSE 3000

CMD ["node", "mywebapp/index.js"]
