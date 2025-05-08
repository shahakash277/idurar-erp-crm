# Backend Dockerfile
FROM node:20
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 8888
CMD ["npm", "start"] 