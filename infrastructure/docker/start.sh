#!/bin/bash
# Korean Together - Production-Ready Container Startup Script
# Version: 2.1 (Fail-Fast + Graceful Shutdown)

set -e

# 색상 출력
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 로그 디렉토리 생성
mkdir -p /app/logs

log_info "🚀 Starting Korean Together Application..."

# =============================================================================
# Cleanup 함수 (Graceful Shutdown)
# =============================================================================
cleanup() {
    log_warn "🛑 Received SIGTERM/SIGINT, shutting down gracefully..."
    
    # AI 서비스 종료
    if [ ! -z "$AI_PID" ]; then
        if kill -0 $AI_PID 2>/dev/null; then
            log_info "Stopping AI service (PID: $AI_PID)..."
            kill -SIGTERM $AI_PID 2>/dev/null || true
        fi
    fi
    
    # API 서버 종료
    if [ ! -z "$API_PID" ]; then
        if kill -0 $API_PID 2>/dev/null; then
            log_info "Stopping API server (PID: $API_PID)..."
            kill -SIGTERM $API_PID 2>/dev/null || true
        fi
    fi
    
    # 최대 10초 대기 (Graceful Shutdown)
    log_info "Waiting for processes to terminate gracefully (max 10s)..."
    for i in {1..10}; do
        AI_ALIVE=$(kill -0 $AI_PID 2>/dev/null && echo "yes" || echo "no")
        API_ALIVE=$(kill -0 $API_PID 2>/dev/null && echo "yes" || echo "no")
        
        if [ "$AI_ALIVE" = "no" ] && [ "$API_ALIVE" = "no" ]; then
            log_info "✅ All processes terminated gracefully"
            exit 0
        fi
        
        sleep 1
    done
    
    # 강제 종료
    log_warn "⚠️ Timeout reached. Force killing remaining processes..."
    kill -9 $AI_PID 2>/dev/null || true
    kill -9 $API_PID 2>/dev/null || true
    
    exit 1
}

# SIGTERM/SIGINT 트랩 설정
trap cleanup SIGTERM SIGINT

# =============================================================================
# AI Service 시작
# =============================================================================
log_info "🤖 Starting AI service (Python FastAPI)..."

cd /app/ai

# 로그 파일 초기화
> /app/logs/ai-service.log

# Uvicorn 시작 (백그라운드)
python3 -m uvicorn main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --log-level info \
    --no-access-log \
    > /app/logs/ai-service.log 2>&1 &

AI_PID=$!
log_info "AI service started (PID: $AI_PID)"

# AI 서비스 헬스체크 (최대 30초)
log_info "Waiting for AI service to be ready..."
AI_READY=false

for i in {1..30}; do
    # PID 체크
    if ! kill -0 $AI_PID 2>/dev/null; then
        log_error "❌ AI service crashed during startup!"
        log_error "Last 20 lines of log:"
        tail -n 20 /app/logs/ai-service.log
        exit 1
    fi
    
    # 헬스체크
    if curl -sf http://localhost:8000/health > /dev/null 2>&1; then
        AI_READY=true
        log_info "✅ AI service is ready (took ${i}s)"
        break
    fi
    
    sleep 1
done

if [ "$AI_READY" = "false" ]; then
    log_error "❌ AI service health check timeout (30s)"
    log_error "Last 20 lines of log:"
    tail -n 20 /app/logs/ai-service.log
    cleanup
    exit 1
fi

# =============================================================================
# API Server 시작
# =============================================================================
log_info "🌐 Starting API server (Node.js Express)..."

cd /app/api

# 로그 파일 초기화
> /app/logs/api-server.log

# Node.js 시작 (백그라운드)
NODE_ENV=${NODE_ENV:-production} \
    node src/index.js \
    > /app/logs/api-server.log 2>&1 &

API_PID=$!
log_info "API server started (PID: $API_PID)"

# API 서버 헬스체크 (최대 30초)
log_info "Waiting for API server to be ready..."
API_READY=false

for i in {1..30}; do
    # PID 체크
    if ! kill -0 $API_PID 2>/dev/null; then
        log_error "❌ API server crashed during startup!"
        log_error "Last 20 lines of log:"
        tail -n 20 /app/logs/api-server.log
        cleanup
        exit 1
    fi
    
    # 헬스체크
    if curl -sf http://localhost:5000/health > /dev/null 2>&1; then
        API_READY=true
        log_info "✅ API server is ready (took ${i}s)"
        break
    fi
    
    sleep 1
done

if [ "$API_READY" = "false" ]; then
    log_error "❌ API server health check timeout (30s)"
    log_error "Last 20 lines of log:"
    tail -n 20 /app/logs/api-server.log
    cleanup
    exit 1
fi

# =============================================================================
# 시작 완료
# =============================================================================
log_info "✅ All services are running successfully!"
echo ""
log_info "📊 Service Status:"
log_info "   - API Server: http://localhost:5000 (PID: $API_PID)"
log_info "   - AI Service: http://localhost:8000 (PID: $AI_PID)"
echo ""
log_info "📁 Logs:"
log_info "   - API: /app/logs/api-server.log"
log_info "   - AI:  /app/logs/ai-service.log"
echo ""

# =============================================================================
# Fail-Fast 모니터링 (무한 루프)
# =============================================================================
log_info "🔍 Monitoring services (Fail-Fast mode)..."
log_info "   Press Ctrl+C to stop gracefully"
echo ""

while true; do
    # API 서버 체크
    if ! kill -0 $API_PID 2>/dev/null; then
        log_error "❌ API server crashed! (PID: $API_PID)"
        log_error "Last 30 lines of API log:"
        tail -n 30 /app/logs/api-server.log
        log_error "Shutting down all services (Fail-Fast)..."
        cleanup
        exit 1
    fi
    
    # AI 서비스 체크
    if ! kill -0 $AI_PID 2>/dev/null; then
        log_error "❌ AI service crashed! (PID: $AI_PID)"
        log_error "Last 30 lines of AI log:"
        tail -n 30 /app/logs/ai-service.log
        log_error "Shutting down all services (Fail-Fast)..."
        cleanup
        exit 1
    fi
    
    # 5초마다 체크
    sleep 5
done
