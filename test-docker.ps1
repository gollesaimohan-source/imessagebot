#!/bin/pwsh
# Quick test script for Docker Compose setup (Windows)

Write-Host "🔍 Checking Docker Compose configuration..." -ForegroundColor Cyan
$configOutput = docker-compose config 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Config valid" -ForegroundColor Green
} else {
    Write-Host "❌ Config invalid" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🚀 Starting services..." -ForegroundColor Cyan
docker-compose down 2>$null
docker-compose up -d

Write-Host ""
Write-Host "⏳ Waiting for services to be ready (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "📊 Service Status:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "🧪 Testing connectivity..." -ForegroundColor Cyan

# Wait for backend to be ready
$backendReady = $false
for ($i = 1; $i -le 30; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Backend health check: PASSED" -ForegroundColor Green
            $backendReady = $true
            break
        }
    } catch {
        # Silent
    }
    if ($i -eq 30) {
        Write-Host "❌ Backend health check: FAILED" -ForegroundColor Red
    }
    Start-Sleep -Seconds 1
}

# Wait for frontend to be ready
$frontendReady = $false
for ($i = 1; $i -le 30; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Frontend health check: PASSED" -ForegroundColor Green
            $frontendReady = $true
            break
        }
    } catch {
        # Silent
    }
    if ($i -eq 30) {
        Write-Host "❌ Frontend health check: FAILED" -ForegroundColor Red
    }
    Start-Sleep -Seconds 1
}

# Test MongoDB
try {
    $mongoTest = docker-compose exec -T mongo mongosh --eval "db.adminCommand('ping')" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ MongoDB health check: PASSED" -ForegroundColor Green
    } else {
        Write-Host "❌ MongoDB health check: FAILED" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ MongoDB health check: FAILED" -ForegroundColor Red
}

Write-Host ""
Write-Host "📍 Service URLs:" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:3000"
Write-Host "   Backend:  http://localhost:5000"
Write-Host "   MongoDB:  localhost:27017"

Write-Host ""
Write-Host "📋 View logs:" -ForegroundColor Cyan
Write-Host "   docker-compose logs -f"

Write-Host ""
Write-Host "❌ Stop all services:" -ForegroundColor Cyan
Write-Host "   docker-compose down"
