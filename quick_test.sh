#!/bin/bash
# Korean Together - 빠른 테스트

echo "🎯 Korean Together - 빠른 테스트"
echo ""

# API Health
echo "1️⃣ API 서버 확인..."
curl -s http://localhost:5000/health | jq -r '"\(.service) v\(.version) - \(.status)"' 2>/dev/null || echo "❌ API 서버 미작동"

# AI Health
echo "2️⃣ AI 서비스 확인..."
curl -s http://localhost:8000/health | jq -r '"\(.service) - \(.status)"' 2>/dev/null || echo "❌ AI 서비스 미작동"

# Database
echo "3️⃣ Database 확인..."
LESSONS=$(docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -t -c "SELECT COUNT(*) FROM lessons;" 2>/dev/null | tr -d ' ')
echo "   레슨: ${LESSONS}개"

echo ""
echo "✅ 빠른 점검 완료"
echo ""
echo "📚 상세 테스트: ./test_complete.sh"
echo "📖 테스트 가이드: HANDS_ON_TESTING.md"
