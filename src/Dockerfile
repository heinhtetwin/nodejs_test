FROM node:14

COPY . /app
WORKDIR /app

RUN npm install

ENV NODE_ENV Testing

EXPOSE 2019

CMD ["npm", "start"]
