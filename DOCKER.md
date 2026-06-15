# Docker Setup Guide for iMessageBot

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Environment variables configured (see below)

## Development Setup

### 1. Create environment file:
```bash
cp .env.example .env
```

Edit `.env` with your configuration:
```env
CLERK_SECRET_KEY=your_clerk_secret_key
CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
MONGODB_URI=mongodb://mongo:27017/imessagebot
CORS_ORIGIN=http://localhost:3000
VITE_API_URL=http://localhost:5000
```

### 2. Start all services:
```bash
docker-compose up -d
```

This will start:
- **Frontend:** http://localhost:3000
- **Backend:** http://localhost:5000
- **MongoDB:** localhost:27017

### 3. View logs:
```bash
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongo
```

### 4. Stop services:
```bash
docker-compose down
```

### 5. Clean up (remove volumes):
```bash
docker-compose down -v
```

---

## Production Deployment

### Option 1: Using docker-compose.prod.yml

```bash
# Create production env file
cp .env.example .env.prod

# Edit with production values
vi .env.prod

# Start services
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

### Option 2: Build and Run Individual Images

```bash
# Build images
docker build -t imessagebot-backend:latest -f backend/Dockerfile .
docker build -t imessagebot-frontend:latest -f frontend/Dockerfile .

# Run backend
docker run -d \
  -p 5000:5000 \
  -e NODE_ENV=production \
  -e MONGODB_URI=your_mongo_uri \
  -e CLERK_SECRET_KEY=your_key \
  -e CLERK_PUBLISHABLE_KEY=your_key \
  -e CORS_ORIGIN=your_domain \
  --name imessagebot-backend \
  imessagebot-backend:latest

# Run frontend
docker run -d \
  -p 80:80 \
  -e VITE_CLERK_PUBLISHABLE_KEY=your_key \
  -e VITE_API_URL=https://api.yourdomain.com \
  --link imessagebot-backend:backend \
  --name imessagebot-frontend \
  imessagebot-frontend:latest
```

---

## File Structure

```
Dockerfile                    - Production backend image
backend/
  └─ Dockerfile              - Backend development/prod image
frontend/
  ├─ Dockerfile              - Frontend production image (nginx)
  └─ nginx.conf              - Nginx reverse proxy configuration
docker-compose.yml           - Development orchestration
docker-compose.prod.yml      - Production orchestration
.dockerignore               - Files excluded from builds
.env.example                - Configuration template
```

---

## Architecture Overview

### Development (docker-compose.yml)
```
┌─────────────────────────────────────────────────┐
│           Docker Compose Network                │
├─────────────────────────────────────────────────┤
│  Frontend (Nginx)     Backend (Node.js)  MongoDB │
│  :3000                :5000              :27017  │
│  ├─ React App         ├─ Express         ├─ DB   │
│  └─ Nginx Proxy       └─ API Routes      └─ Data │
└─────────────────────────────────────────────────┘
```

### Production (docker-compose.prod.yml)
```
┌────────────────────────────────────────────────────┐
│        Docker Compose Production Network           │
├────────────────────────────────────────────────────┤
│  Frontend              Backend              MongoDB │
│  (Nginx - Port 80)     (Node - Port 5000)  (:27017)│
│  - Static assets       - API endpoints      - Data │
│  - SPA routing         - Business logic     - Cache │
│  - Reverse proxy       - Webhooks           - Logs  │
│  - SSL/TLS ready       - Auth handling             │
└────────────────────────────────────────────────────┘
```

---

## Docker Images Used

| Service | Image | Size | Purpose |
|---------|-------|------|---------|
| Backend | node:20-alpine | ~190MB | Express.js server |
| Frontend | nginx:alpine | ~45MB | Static asset serving & proxy |
| Database | mongo:7-alpine | ~150MB | Data persistence |

---

## Key Features

✅ **Development**
- Live code reloading with volume mounts
- Easy local testing
- MongoDB included
- Debug logging enabled

✅ **Production**
- Multi-stage builds for optimized images
- Health checks for all services
- Resource limits and reservations
- Security best practices
- Automatic restart policies
- Proper signal handling

✅ **Networking**
- Internal service communication via Docker network
- Backend accessible at `http://backend:5000`
- MongoDB accessible at `mongodb://mongo:27017`
- Frontend accessible at `http://localhost` (prod) or `http://localhost:3000` (dev)

✅ **Performance**
- Gzip compression enabled
- Asset caching configured
- Minimal base images (Alpine Linux)
- Multi-stage builds reduce final image size

---

## Common Commands

### Development
```bash
# Start all services
docker-compose up -d

# View real-time logs
docker-compose logs -f

# Stop services
docker-compose stop

# Restart a service
docker-compose restart backend

# Rebuild images
docker-compose build --no-cache

# Run a command in container
docker-compose exec backend npm install
docker-compose exec mongo mongosh

# Remove everything
docker-compose down -v
```

### Production
```bash
# Start with production config
docker-compose -f docker-compose.prod.yml up -d

# Scale services
docker-compose -f docker-compose.prod.yml up -d --scale backend=3

# Check service status
docker-compose -f docker-compose.prod.yml ps

# View production logs
docker-compose -f docker-compose.prod.yml logs -f
```

---

## Troubleshooting

### Nginx can't connect to backend
```bash
# Check if backend is running
docker-compose ps

# Check backend logs
docker-compose logs backend

# Restart frontend to reconnect
docker-compose restart frontend
```

### MongoDB connection fails
```bash
# Check if MongoDB is healthy
docker-compose logs mongo

# Verify connection string
docker-compose exec backend echo $MONGODB_URI

# Restart MongoDB
docker-compose restart mongo
```

### Port already in use
```bash
# Find what's using the port
lsof -i :3000  # Linux/Mac
Get-Process -Id (Get-NetTCPConnection -LocalPort 3000).OwningProcess  # Windows

# Use different ports in docker-compose.yml
# Change "3000:80" to "8000:80"
```

### Container won't start
```bash
# View detailed logs
docker-compose logs -f service_name

# Check image built correctly
docker images | grep imessagebot

# Rebuild from scratch
docker-compose build --no-cache service_name
```

### Need fresh database
```bash
# Remove MongoDB volume
docker-compose down -v

# Start fresh
docker-compose up -d
```

---

## Environment Variables

### Backend
| Variable | Required | Example |
|----------|----------|---------|
| `NODE_ENV` | Yes | `development` / `production` |
| `MONGODB_URI` | Yes | `mongodb://mongo:27017/imessagebot` |
| `CLERK_SECRET_KEY` | Yes | Your Clerk secret |
| `CLERK_PUBLISHABLE_KEY` | Yes | Your Clerk publishable key |
| `CORS_ORIGIN` | Yes | `http://localhost:3000` |

### Frontend
| Variable | Required | Example |
|----------|----------|---------|
| `VITE_CLERK_PUBLISHABLE_KEY` | Yes | Your Clerk publishable key |
| `VITE_API_URL` | Yes | `http://localhost:5000` |

---

## Security Checklist

- [ ] Use `.env` for secrets, never commit to git
- [ ] Enable HTTPS/TLS in production
- [ ] Set resource limits (memory, CPU)
- [ ] Keep base images updated
- [ ] Use health checks
- [ ] Configure CORS properly
- [ ] Use strong MongoDB passwords
- [ ] Implement rate limiting
- [ ] Enable logging and monitoring
- [ ] Regular security scans: `docker scan imessagebot-backend`

---

## Performance Tips

1. **Use Alpine images** - Already implemented (~45-190MB vs 300-900MB)
2. **Multi-stage builds** - Reduces final image size
3. **Layer caching** - Order Dockerfile commands efficiently
4. **Volume mounts** - Use bind mounts for development only
5. **Resource limits** - Prevent runaway containers
6. **Health checks** - Automatic recovery from failures
7. **Gzip compression** - Reduce bandwidth (nginx configured)
8. **Asset caching** - Static files cached for 1 year

---

## Notes

- Backend service runs on port 5000 internally, exposed on 5000
- Frontend service runs on port 80 (nginx), exposed on 3000 (dev) or 80 (prod)
- All services communicate through `imessagebot-network` bridge network
- MongoDB data persists in `mongodb_data` volume
- Source code volumes are only mounted in development mode

