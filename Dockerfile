# ---------- Build stage ----------
FROM node:18-alpine AS build

WORKDIR /app

# Required for old react-scripts + webpack
ENV NODE_OPTIONS=--openssl-legacy-provider

# Copy dependency files (ROOT level)
COPY package.json package-lock.json ./

RUN npm ci

# Copy application source
COPY src ./src
COPY public ./public

RUN npm run build

# ---------- Runtime stage ----------
FROM node:18-alpine

WORKDIR /app

RUN npm install -g serve

COPY --from=build /app/build ./build

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]

