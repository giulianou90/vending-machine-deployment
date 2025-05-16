FROM node:20-alpine AS builder

WORKDIR /app

COPY . .

RUN npm install

RUN npm run build

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app .

RUN npm install --only=production

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["node", "dist/app.js"]
