FROM node:18

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

# Build the dashboard
WORKDIR /app/dashboard
RUN npm run build

# Set working directory for app startup
WORKDIR /app

EXPOSE 3000

CMD ["npm", "start"]
