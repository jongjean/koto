#!/bin/bash
# Korean Together - 배포 스크립트

set -e

echo "🚀 Korean Together 배포 시작..."
echo ""

# 1. 배포 폴더 확인
if [ ! -d "/var/www/koto" ]; then
    sudo mkdir -p /var/www/koto
    sudo chown -R $USER:$USER /var/www/koto
    echo "✅ 배포 폴더 생성"
fi

# 2. 파일 복사
echo "📦 파일 복사 중..."
rsync -av --delete \
    --exclude 'node_modules' \
    --exclude 'venv' \
    --exclude '__pycache__' \
    --exclude '.git' \
    --exclude '*.log' \
    /home/ucon/koto/ /var/www/koto/

echo "✅ 파일 복사 완료"
echo ""

# 3. Node.js 의존성 설치
echo "📦 API 서버 의존성 설치..."
cd /var/www/koto/api
npm install --production
echo "✅ API 의존성 설치 완료"
echo ""

# 4. Python 가상환경 생성
echo "🐍 AI 서비스 환경 설정..."
cd /var/www/koto/ai
python3 -m venv venv
source venv/bin/activate
pip install -q -r requirements.txt
deactivate
echo "✅ AI 환경 설정 완료"
echo ""

# 5. Caddy 설정 복사
if [ -f "/var/www/koto/infrastructure/caddy/Caddyfile.koto" ]; then
    echo "📋 Caddy 설정 안내:"
    echo "   1. /etc/caddy/Caddyfile에 다음 내용 추가:"
    echo "   2. sudo nano /etc/caddy/Caddyfile"
    echo "   3. import /var/www/koto/infrastructure/caddy/Caddyfile.koto"
    echo "   4. sudo systemctl reload caddy"
fi
echo ""

# 6. 완료
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Korean Together 배포 완료!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📱 모바일 테스트:"
echo "   http://koto.uconcreative.ddns.net/mobile-test.html"
echo ""
echo "🔧 서버 시작:"
echo "   cd /var/www/koto/api && npm run dev &"
echo "   cd /var/www/koto/ai && source venv/bin/activate && python main.py &"
echo ""
echo "📚 문서:"
echo "   /var/www/koto/README.md"
echo "   /var/www/koto/MOBILE_TESTING.md"
