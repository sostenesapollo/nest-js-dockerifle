FROM node:16-alpine as builder
WORKDIR /app
RUN apk add g++ make python3
COPY package*.json ./
COPY prisma ./prisma/
COPY .env.example ./.env
COPY tsconfig.json ./
COPY . .
RUN npm install -ci
RUN npm rebuild bcrypt --build-from-source
RUN npx prisma generate
RUN npm run build
RUN apk del g++ make python3

FROM node:16-alpine
WORKDIR /app
RUN npm install pm2 -g
COPY --from=builder /app/dist .
COPY --from=builder /app/.env .env
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD [ "pm2-runtime", "src/main.js" ]
