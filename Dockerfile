# Build stage
FROM node:20-alpine AS builder

# SET THE WORKDIR TO /app/web FROM THE START
WORKDIR /app/web

# Copy package files first for better caching
# Now we are already in /app/web, so we copy from the host's web/ to the current (./)
COPY ./package.json ./package-lock.json* ./
RUN npm ci

# Copy the rest of the web app source code
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine AS production
WORKDIR /app/web

# Install production dependencies only
COPY ./package.json ./package-lock.json* ./
RUN npm ci --omit=dev

# Copy built application from builder stage
COPY --from=builder /app/web/.next ./.next
COPY --from=builder /app/web/public ./public
COPY --from=builder /app/web/node_modules ./node_modules

# Expose port and set environment
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Start the application
CMD ["npm", "start"]
