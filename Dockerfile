FROM node:18-slim

WORKDIR /app

COPY . .

EXPOSE 3005

RUN apt update -y &&\
    chmod +x index.js &&\
    npm install 
    
CMD ["node", "index.js"]
