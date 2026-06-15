#!/bin/bash
# Quick test script for Docker Compose setup

echo "🔍 Checking Docker Compose configuration..."
docker-compose config > /dev/null && echo "✅ Config valid" || echo "❌ Config invalid"

echo ""
echo "🚀 Starting services..."
docker-compose down 2>/dev/null
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready (30 seconds)..."
sleep 10

echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "🧪 Testing connectivity..."

# Wait for backend to be ready
for i in {1..30}; do
    if curl -s http://localhost:5000/health > /dev/null 2>&1; then
        echo "✅ Backend health check: PASSED"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Backend health check: FAILED"
    fi
    sleep 1
done

# Wait for frontend to be ready
for i in {1..30}; do
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        echo "✅ Frontend health check: PASSED"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Frontend health check: FAILED"
    fi
    sleep 1
done

# Test MongoDB
if docker-compose exec -T mongo mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo "✅ MongoDB health check: PASSED"
else
    echo "❌ MongoDB health check: FAILED"
fi

echo ""
echo "📍 Service URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:5000"
echo "   MongoDB:  localhost:27017"

echo ""
echo "📋 View logs:"
echo "   docker-compose logs -f"

echo ""
echo "❌ Stop all services:"
echo "   docker-compose down"
