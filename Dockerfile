FROM node:16-alpine

ENV NODE_OPTIONS="--max-old-space-size=4096"

RUN apk add --no-cache python3 make g++ git

WORKDIR /app

# Copy and install backend dependencies (include dev for tsc)
COPY backend/package*.json ./backend/
WORKDIR /app/backend
RUN npm ci --prefer-offline --no-audit --progress=false

# Copy and install dashboard deps (prod only)
WORKDIR /app
COPY dashboard/package*.json ./dashboard/
WORKDIR /app/dashboard
RUN npm ci --only=production --prefer-offline --no-audit --progress=false

# Root dev deps for tsc in build script
WORKDIR /app
COPY package*.json ./
RUN npm ci --prefer-offline --no-audit --progress=false

# Copy source
COPY . .

# Build backend (uses root tsc)
RUN npm run build

# Build dashboard
WORKDIR /app/dashboard
RUN npm run build

WORKDIR /app
RUN npm prune --production && npm cache clean --force

USER node
EXPOSE 3000
CMD ["npm", "start"]