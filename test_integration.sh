#!/bin/bash
# Korean Together ver0.1 Integration Test
# Tests the complete flow: Session → Activity → Evaluate → TTS

set -e

echo "🧪 Korean Together ver0.1 Integration Test"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test results
PASSED=0
FAILED=0

test_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((PASSED++))
}

test_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((FAILED++))
}

# =============================================================================
# Test 1: API Server Health
# =============================================================================
echo "Test 1: API Server Health Check"
RESPONSE=$(curl -s http://localhost:5000/health)
if echo "$RESPONSE" | grep -q "OK"; then
    test_pass "API Server is running"
else
    test_fail "API Server health check failed"
fi
echo ""

# =============================================================================
# Test 2: Database Connection
# =============================================================================
echo "Test 2: Database - Lesson Data"
LESSON_COUNT=$(docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -t -c "SELECT COUNT(*) FROM lessons WHERE code = 'les_greeting_001';")
if [ "$LESSON_COUNT" -eq 1 ]; then
    test_pass "Lesson data exists"
else
    test_fail "Lesson data not found"
fi

ACTIVITY_COUNT=$(docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -t -c "SELECT COUNT(*) FROM activities WHERE stage_id = '00000000-0000-0000-0001-000000000001';")
if [ "$ACTIVITY_COUNT" -eq 5 ]; then
    test_pass "5 activities loaded"
else
    test_fail "Activities not loaded correctly"
fi
echo ""

# =============================================================================
# Test 3: Create Session
# =============================================================================
echo "Test 3: Create Session API"
USER_ID="00000000-0000-0000-0000-000000000001"  # test_user
LESSON_ID="00000000-0000-0000-0000-000000000001"  # Greetings

SESSION_RESPONSE=$(curl -s -X POST http://localhost:5000/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d "{\"user_id\": \"$USER_ID\", \"lesson_id\": \"$LESSON_ID\"}")

SESSION_ID=$(echo "$SESSION_RESPONSE" | jq -r '.session_id')

if [ "$SESSION_ID" != "null" ] && [ -n "$SESSION_ID" ]; then
    test_pass "Session created: $SESSION_ID"
else
    test_fail "Session creation failed"
fi
echo ""

# =============================================================================
# Test 4: AI Service Health (if running)
# =============================================================================
echo "Test 4: AI Service Health Check"
AI_RESPONSE=$(curl -s http://localhost:8000/health 2>/dev/null || echo "not_running")
if echo "$AI_RESPONSE" | grep -q "OK"; then
    test_pass "AI Service is running"
    
    # Extended check for Gemini config
    if echo "$AI_RESPONSE" | grep -q "gemini_configured.*true"; then
        test_pass "Gemini API configured"
    else
        test_fail "Gemini API not configured"
    fi
else
    echo -e "${YELLOW}⚠️ SKIP${NC}: AI Service not running (start with: cd ai && source venv/bin/activate && uvicorn main:app)"
fi
echo ""

# =============================================================================
# Test 5: Evaluation API (if AI service running)
# =============================================================================
if echo "$AI_RESPONSE" | grep -q "OK"; then
    echo "Test 5: Evaluation API"
    
    EVAL_RESPONSE=$(curl -s -X POST http://localhost:8000/api/v1/evaluate \
      -H "Content-Type: application/json" \
      -d '{
        "user_text": "안녕하세요",
        "expected_pattern": "안녕하세요",
        "context": {"lang_pack": "ko-en", "difficulty": 1}
      }')
    
    SCORE=$(echo "$EVAL_RESPONSE" | jq -r '.score')
    SOURCE=$(echo "$EVAL_RESPONSE" | jq -r '.source')
    
    if [ "$SCORE" -eq 100 ]; then
        test_pass "Evaluation scored 100 (source: $SOURCE)"
    else
        test_fail "Evaluation failed or wrong score: $SCORE"
    fi
    echo ""
fi

# =============================================================================
# Summary
# =============================================================================
echo "=========================================="
echo "Test Summary:"
echo -e "  ${GREEN}Passed${NC}: $PASSED"
echo -e "  ${RED}Failed${NC}: $FAILED"
echo "=========================================="

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
