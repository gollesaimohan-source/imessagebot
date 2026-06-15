# Production Dockerfile - Use docker-compose for local development
# For production deployments, build images separately:
#   docker build -t imessagebot-backend:latest -f backend/Dockerfile .
#   docker build -t imessagebot-frontend:latest -f frontend/Dockerfile .

# This file is an example for single-image production deployment
# It's recommended to use docker-compose or separate container orchestration

# Stage 1: Backend builder
FROM node:20-alpine AS backend-builder

WORKDIR /app/backend

COPY backend/package*.json ./
RUN npm install --production

COPY backend/src ./src

# Stage 2: Frontend builder
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm install

COPY frontend/ .
RUN npm run build

# Stage 3: Frontend runtime (nginx)
FROM nginx:alpine AS frontend-runtime

WORKDIR /app

COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html

EXPOSE 80

# Stage 4: Backend runtime with frontend
FROM node:20-alpine

RUN apk add --no-cache dumb-init

WORKDIR /app

# Copy backend
COPY --from=backend-builder /app/backend .

# Copy frontend public files to serve static content
COPY --from=frontend-builder /app/frontend/dist ./public

# Install production dependencies only
RUN npm install --production

EXPOSE 5000

# Use dumb-init to handle signals properly
ENTRYPOINT ["/usr/sbin/dumb-init", "--"]

# Start backend (frontend should be served separately)
CMD ["node", "src/index.js"]
