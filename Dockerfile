FROM node:16-alpine

ENV NODE_OPTIONS="--max-old-space-size=4096"

RUN apk add --no-cache python3 make g++ git

WORKDIR /app

# Backend deps with dev
COPY backend/package*.json ./backend/
WORKDIR /app/backend
RUN npm ci --prefer-offline --no-audit --progress=false

# Dashboard deps with dev (needed for cross-env/webpack)
WORKDIR /app
COPY dashboard/package*.json ./dashboard/
WORKDIR /app/dashboard
RUN npm ci --prefer-offline --no-audit --progress=false

# Root deps with dev
WORKDIR /app
COPY package*.json ./
RUN npm ci --prefer-offline --no-audit --progress=false

# Copy source
COPY . .

# Build backend
RUN npm run build

# Build dashboard
WORKDIR /app/dashboard
RUN npm run build

# Prune to production for runtime
WORKDIR /app
RUN npm prune --production && npm cache clean --force && (cd backend && npm prune --production) && (cd dashboard && npm prune --production)

USER node
EXPOSE 3000
CMD ["npm", "start"]