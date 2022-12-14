# Base image
FROM node:alpine
# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
# Install app dependencies
COPY package.json ./
RUN npm install
# Bundle app source
COPY . .


EXPOSE 8080
CMD [ "node", "server.js" ]
