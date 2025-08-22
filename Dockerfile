# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files first for better caching - NOTE THE 'web/' PATH!
COPY ./web/package.json ./web/package-lock.json* ./
RUN npm ci

# Copy source code and build - NOTE THE 'web/' PATH!
COPY ./web/ ./
RUN npm run build

# Production stage
FROM node:20-alpine AS production
WORKDIR /app

# Install production dependencies only - NOTE THE 'web/' PATH!
COPY ./web/package.json ./web/package-lock.json* ./
RUN npm ci --omit=dev

# Copy built application from builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

# Expose port and set environment
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Start the application
CMD ["npm", "start"]
