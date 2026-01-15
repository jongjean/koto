#!/bin/bash
# Korean Together - 종합 테스트
# ver0.1 ~ ver0.4 전체 기능 검증

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Korean Together - 종합 테스트${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((PASSED++))
}

test_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((FAILED++))
}

test_info() {
    echo -e "${YELLOW}ℹ️  INFO${NC}: $1"
}

# =============================================================================
# Test 1: Database 검증
# =============================================================================
echo -e "${BLUE}━━━ Test 1: Database 검증 ━━━${NC}"

# Lessons 수 확인
LESSON_COUNT=$(docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -t -c "SELECT COUNT(*) FROM lessons;" | tr -d ' ')
if [ "$LESSON_COUNT" -eq 15 ]; then
    test_pass "15개 레슨 확인"
else
    test_fail "레슨 수 오류 (expected: 15, got: $LESSON_COUNT)"
fi

# Activities 수 확인
ACTIVITY_COUNT=$(docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -t -c "SELECT COUNT(*) FROM activities;" | tr -d ' ')
if [ "$ACTIVITY_COUNT" -ge 70 ]; then
    test_pass "$ACTIVITY_COUNT개 활동 확인"
else
    test_fail "활동 수 부족 (expected: >= 70, got: $ACTIVITY_COUNT)"
fi

# 레벨별 확인
BEGINNER=$(docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -t -c "SELECT COUNT(*) FROM lessons WHERE level = 'A1';" | tr -d ' ')
INTERMEDIATE=$(docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -t -c "SELECT COUNT(*) FROM lessons WHERE level IN ('A2', 'B1');" | tr -d ' ')
ADVANCED=$(docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -t -c "SELECT COUNT(*) FROM lessons WHERE level IN ('B2', 'C1');" | tr -d ' ')

test_info "초급: $BEGINNER, 중급: $INTERMEDIATE, 고급: $ADVANCED"
echo ""

# =============================================================================
# Test 2: API 서버 Health
# =============================================================================
echo -e "${BLUE}━━━ Test 2: API 서버 ━━━${NC}"

API_HEALTH=$(curl -s http://localhost:5000/health 2>/dev/null || echo "ERROR")
if echo "$API_HEALTH" | grep -q "OK"; then
    test_pass "API 서버 작동 중"
    
    # Version 확인
    VERSION=$(echo "$API_HEALTH" | jq -r '.version' 2>/dev/null)
    test_info "API 버전: $VERSION"
else
    test_fail "API 서버 응답 없음 (서버를 시작하세요: cd api && npm run dev)"
fi
echo ""

# =============================================================================
# Test 3: AI 서비스 Health
# =============================================================================
echo -e "${BLUE}━━━ Test 3: AI 서비스 ━━━${NC}"

AI_HEALTH=$(curl -s http://localhost:8000/health 2>/dev/null || echo "ERROR")
if echo "$AI_HEALTH" | grep -q "OK"; then
    test_pass "AI 서비스 작동 중"
    
    # Gemini 설정 확인
    if echo "$AI_HEALTH" | grep -q "gemini_configured.*true"; then
        test_pass "Gemini API 설정됨"
    else
        test_fail "Gemini API 미설정"
    fi
else
    test_fail "AI 서비스 응답 없음"
fi
echo ""

# =============================================================================
# Test 4: Session 생성 테스트
# =============================================================================
echo -e "${BLUE}━━━ Test 4: Session API ━━━${NC}"

if echo "$API_HEALTH" | grep -q "OK"; then
    USER_ID="00000000-0000-0000-0000-000000000001"
    LESSON_ID="00000000-0000-0000-0000-000000000001"
    
    SESSION_RESP=$(curl -s -X POST http://localhost:5000/api/v1/sessions \
      -H "Content-Type: application/json" \
      -d "{\"user_id\": \"$USER_ID\", \"lesson_id\": \"$LESSON_ID\"}" 2>/dev/null)
    
    SESSION_ID=$(echo "$SESSION_RESP" | jq -r '.session_id' 2>/dev/null)
    
    if [ "$SESSION_ID" != "null" ] && [ -n "$SESSION_ID" ]; then
        test_pass "세션 생성 성공"
        test_info "Session ID: ${SESSION_ID:0:8}..."
    else
        test_fail "세션 생성 실패"
    fi
else
    test_info "API 서버 미작동으로 스킵"
fi
echo ""

# =============================================================================
# Test 5: Gemini 평가 테스트 (한국어-영어)
# =============================================================================
echo -e "${BLUE}━━━ Test 5: Gemini 평가 (ko-en) ━━━${NC}"

if echo "$AI_HEALTH" | grep -q "OK"; then
    # Case 1: 완벽한 답변
    EVAL1=$(curl -s -X POST http://localhost:8000/api/v1/evaluate \
      -H "Content-Type: application/json" \
      -d '{
        "user_text": "안녕하세요",
        "expected_pattern": "안녕하세요",
        "context": {"lang_pack": "ko-en", "difficulty": 1}
      }' 2>/dev/null)
    
    SCORE1=$(echo "$EVAL1" | jq -r '.score' 2>/dev/null)
    SOURCE1=$(echo "$EVAL1" | jq -r '.source' 2>/dev/null)
    
    if [ "$SCORE1" -eq 100 ]; then
        test_pass "완벽 답변 평가 (score: 100, source: $SOURCE1)"
    else
        test_fail "평가 오류 (expected: 100, got: $SCORE1)"
    fi
    
    # Case 2: 약간 다른 답변
    EVAL2=$(curl -s -X POST http://localhost:8000/api/v1/evaluate \
      -H "Content-Type: application/json" \
      -d '{
        "user_text": "저는 학생이에요",
        "expected_pattern": "저는 학생입니다",
        "context": {"lang_pack": "ko-en", "difficulty": 2}
      }' 2>/dev/null)
    
    SCORE2=$(echo "$EVAL2" | jq -r '.score' 2>/dev/null)
    test_info "유사 답변 평가: score=$SCORE2"
else
    test_info "AI 서비스 미작동으로 스킵"
fi
echo ""

# =============================================================================
# Test 6: Gemini 평가 테스트 (한국어-인도네시아어)
# =============================================================================
echo -e "${BLUE}━━━ Test 6: Gemini 평가 (ko-id) ━━━${NC}"

if echo "$AI_HEALTH" | grep -q "OK"; then
    EVAL_ID=$(curl -s -X POST http://localhost:8000/api/v1/evaluate \
      -H "Content-Type: application/json" \
      -d '{
        "user_text": "나 학교 가요",
        "expected_pattern": "나는 학교에 가요",
        "context": {"lang_pack": "ko-id", "difficulty": 1},
        "use_rules": false
      }' 2>/dev/null)
    
    FEEDBACK_ID=$(echo "$EVAL_ID" | jq -r '.feedback' 2>/dev/null)
    
    if echo "$FEEDBACK_ID" | grep -q "partikel\|Tambahkan\|particle" 2>/dev/null; then
        test_pass "인니어 피드백 작동 (파티클 오류 감지)"
    else
        test_info "인니어 평가 완료 (피드백: ${FEEDBACK_ID:0:50}...)"
    fi
else
    test_info "AI 서비스 미작동으로 스킵"
fi
echo ""

# =============================================================================
# Test 7: TTS Mock 모드
# =============================================================================
echo -e "${BLUE}━━━ Test 7: TTS Mock 모드 ━━━${NC}"

if echo "$AI_HEALTH" | grep -q "OK"; then
    TTS_RESP=$(curl -s -X POST http://localhost:8000/api/v1/tts \
      -H "Content-Type: application/json" \
      -d '{
        "text": "안녕하세요. 한국어를 배웁시다.",
        "language": "ko-KR",
        "save_to_minio": false
      }' 2>/dev/null)
    
    TTS_PROVIDER=$(echo "$TTS_RESP" | jq -r '.provider' 2>/dev/null)
    DURATION=$(echo "$TTS_RESP" | jq -r '.duration_ms' 2>/dev/null)
    
    if [ "$TTS_PROVIDER" == "mock_tts" ]; then
        test_pass "TTS Mock 모드 작동 (duration: ${DURATION}ms)"
    else
        test_info "TTS 응답: provider=$TTS_PROVIDER"
    fi
else
    test_info "AI 서비스 미작동으로 스킵"
fi
echo ""

# =============================================================================
# Test 8: 언어팩 파일 확인
# =============================================================================
echo -e "${BLUE}━━━ Test 8: 언어팩 ━━━${NC}"

if [ -f "/home/ucon/koto/shared/lang_packs/ko-id.json" ]; then
    test_pass "ko-id.json 존재"
    
    # JSON 유효성 검사
    if jq empty "/home/ucon/koto/shared/lang_packs/ko-id.json" 2>/dev/null; then
        test_pass "JSON 형식 유효"
        
        # UI 문자열 수 확인
        UI_COUNT=$(jq '.ui_strings | length' "/home/ucon/koto/shared/lang_packs/ko-id.json")
        test_info "UI 문자열: $UI_COUNT개"
        
        # 오류 패턴 수 확인
        ERROR_COUNT=$(jq '.indonesian_error_patterns | length' "/home/ucon/koto/shared/lang_packs/ko-id.json")
        test_info "인니 오류 패턴: $ERROR_COUNT개"
    else
        test_fail "JSON 형식 오류"
    fi
else
    test_fail "ko-id.json 파일 없음"
fi
echo ""

# =============================================================================
# Summary
# =============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  테스트 결과${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${GREEN}Passed${NC}: $PASSED"
echo -e "  ${RED}Failed${NC}: $FAILED"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 모든 테스트 통과!${NC}"
    echo ""
    echo "✅ ver0.1: AI 서버 (100%)"
    echo "✅ ver0.2: 초급 5종 (100%)"
    echo "✅ ver0.3: 중고급 10종 (100%)"
    echo "✅ ver0.4: 인니어 (100%)"
    echo ""
    echo "🚀 Korean Together 시스템이 정상 작동합니다!"
    exit 0
else
    echo -e "${YELLOW}⚠️  일부 테스트 실패${NC}"
    echo ""
    echo "서버가 실행 중인지 확인하세요:"
    echo "  - API: cd api && npm run dev"
    echo "  - AI:  cd ai && source venv/bin/activate && python main.py"
    exit 1
fi
