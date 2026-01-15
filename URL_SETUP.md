# 🌐 Korean Together - 공개 URL 설정

## Option 1: 서브도메인 (별도)
```
http://koto.uconcreative.ddns.net/
```

**Caddyfile**:
```
import /var/www/koto/infrastructure/caddy/Caddyfile.koto
```

---

## Option 2: 서브패스 (추천!) ✅
```
http://uconai.ddns.net/koto/
```

**Caddyfile** (기존 uconai.ddns.net 설정에 추가):
```
uconai.ddns.net {
    # 기존 설정...
    
    # Korean Together
    handle_path /koto/* {
        reverse_proxy localhost:5000
    }
    
    handle_path /koto-ai/* {
        reverse_proxy localhost:8000
    }
}
```

또는:
```
import /var/www/koto/infrastructure/caddy/Caddyfile.koto.path
```

---

## 설정 방법

### 1. Caddyfile 편집
```bash
sudo nano /etc/caddy/Caddyfile
```

### 2. Korean Together 설정 추가
```
# uconai.ddns.net 블록 안에 추가
handle_path /koto/* {
    reverse_proxy localhost:5000
}

handle_path /koto-ai/* {
    reverse_proxy localhost:8000
}
```

### 3. Caddy 재시작
```bash
sudo systemctl reload caddy
```

---

## 접속 테스트

### 웹 인터페이스
```
http://uconai.ddns.net/koto/
```

### API Health Check
```
http://uconai.ddns.net/koto/health
```

### AI Health Check
```
http://uconai.ddns.net/koto-ai/health
```

---

## 서버 시작

```bash
# API (port 5000)
cd /var/www/koto/api && npm run dev &

# AI (port 8000)
cd /var/www/koto/ai && source venv/bin/activate && python main.py &
```

---

**추천 URL**: `http://uconai.ddns.net/koto/` ✅
