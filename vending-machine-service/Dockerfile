FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY tsconfig.json ./
COPY src ./src

RUN npm run build

FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY --from=builder /app/dist ./dist

COPY example.env .env

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["node", "dist/app.js"]
