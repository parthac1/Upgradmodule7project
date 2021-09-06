FROM node:alpine

    WORKDIR /app


 COPY ./nodeapp .

 RUN yarn install --production
 
 
 CMD ["node", "server.js"]
