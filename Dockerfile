# Build a minimal image
FROM node:20-alpine

WORKDIR /app

# Install deps (no lockfile required)
COPY package.json ./
RUN npm install --omit=dev

# Copy app files
COPY server.js ./
COPY public ./public

# Ensure uploads dir exists
RUN mkdir -p /app/uploads

EXPOSE 3000

# Optional: allow overriding max upload size via env
ENV MAX_FILE_SIZE=52428800

# Run
CMD ["node", "server.js"]
