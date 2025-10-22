FROM node:16

# Allow older Webpack and crypto
ENV NODE_OPTIONS=--openssl-legacy-provider

# Set up app root & install top-level dependencies
WORKDIR /app
COPY package*.json ./
RUN npm install

# Set up dashboard dependencies
WORKDIR /app/dashboard
COPY dashboard/package*.json ./
RUN npm install

# Copy all source code into the image
WORKDIR /app
COPY . .

# Build the backend TypeScript
RUN npm run build

# Build the dashboard
WORKDIR /app/dashboard
RUN npm run build

# Set working directory for app startup
WORKDIR /app

EXPOSE 3000

CMD ["node", "dist/index.js"]
