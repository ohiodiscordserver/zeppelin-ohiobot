FROM node:16-alpine

# Set memory limit for Node.js
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Install system dependencies
RUN apk add --no-cache python3 make g++ git

# Set up app root
WORKDIR /app

# Copy and install backend dependencies first (for better Docker caching)
COPY backend/package*.json ./backend/
WORKDIR /app/backend
RUN npm ci --only=production --prefer-offline --no-audit --progress=false

# Copy and install dashboard dependencies
WORKDIR /app
COPY dashboard/package*.json ./dashboard/
WORKDIR /app/dashboard
RUN npm ci --only=production --prefer-offline --no-audit --progress=false

# Copy root package.json for build scripts
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --prefer-offline --no-audit --progress=false

# Copy all source code
COPY . .

# Build the backend TypeScript
RUN npm run build

# Build the dashboard
WORKDIR /app/dashboard
RUN npm run build

# Back to app root
WORKDIR /app

# Clean up dev dependencies and cache to reduce image size
RUN npm cache clean --force

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000

CMD ["npm", "start"]