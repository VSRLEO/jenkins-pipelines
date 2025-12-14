# ---------- Build stage ----------
FROM node:18-alpine AS build

WORKDIR /app

ENV NODE_OPTIONS=--openssl-legacy-provider

COPY package*.json ./
RUN npm ci

COPY src ./src
COPY public ./public
COPY app ./app

RUN npm run build

# ---------- Runtime stage ----------
FROM node:18-alpine

WORKDIR /app

RUN npm install -g serve

COPY --from=build /app/build ./build

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]

