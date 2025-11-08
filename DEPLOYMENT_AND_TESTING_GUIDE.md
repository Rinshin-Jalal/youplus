# Deployment & Testing Guide

## Status: Ready for Infrastructure Setup + Testing

This guide covers the final steps to get your You+ AI agent into production:
- **Phase 1.1**: LiveKit Cloud Setup (10 minutes)
- **Phase 1.3**: Supermemory Setup (5 minutes)
- **Phase 6**: Testing & Rollout (60+ minutes)

---

## Phase 1.1: LiveKit Cloud Setup (10 minutes)

### Step 1: Create LiveKit Account

1. Go to **https://cloud.livekit.io**
2. Sign up or log in with email/GitHub
3. Create a new project (e.g., "YouPlus")

### Step 2: Generate API Credentials

1. In your project, go to **Settings** → **API Keys**
2. Click **Generate Token**
3. Keep both public and secret keys safe
4. Copy the connection URL (format: `wss://your-project.livekit.cloud`)

### Step 3: Configure Environment Variables

**For Agent** (`/agent/.env`):
```bash
LIVEKIT_URL=wss://your-project.livekit.cloud
LIVEKIT_API_KEY=your_public_key
LIVEKIT_API_SECRET=your_secret_key
CARTESIA_API_KEY=your_cartesia_key
OPENAI_API_KEY=your_openai_key
SUPERMEMORY_API_KEY=your_supermemory_key  # Optional but recommended
```

**For Backend** (`/be/wrangler.toml`):
```toml
env.production.vars = {
    LIVEKIT_URL = "wss://your-project.livekit.cloud",
    LIVEKIT_API_KEY = "your_public_key",
    LIVEKIT_API_SECRET = "your_secret_key",
}
```

**For iOS App** (in Xcode):
- Update `LIVEKIT_URL` constant in `AppDelegate+LiveKit.swift`
- Update bundle identifier if needed
- Ensure VoIP capabilities are enabled

### Step 4: Verify LiveKit Setup

```bash
cd /agent

# Test connection
python3 -c "
import os
from dotenv import load_dotenv
load_dotenv()

url = os.getenv('LIVEKIT_URL')
api_key = os.getenv('LIVEKIT_API_KEY')
api_secret = os.getenv('LIVEKIT_API_SECRET')

if all([url, api_key, api_secret]):
    print('✅ LiveKit credentials configured correctly')
    print(f'   URL: {url}')
else:
    print('❌ Missing LiveKit credentials')
"
```

---

## Phase 1.3: Supermemory Setup (5 minutes)

### Step 1: Create Supermemory Account

1. Go to **https://supermemory.ai**
2. Click **Sign Up**
3. Create account with email
4. Verify email address

### Step 2: Generate API Key

1. Log in to dashboard
2. Go to **Settings** → **API Keys**
3. Click **Create New Key**
4. Copy the key (starts with `smem_`)

### Step 3: Add to Environment

**In `/agent/.env`**:
```bash
SUPERMEMORY_API_KEY=smem_your_key_here
SUPERMEMORY_BASE_URL=https://api.supermemory.ai
```

### Step 4: Verify Supermemory Setup

```bash
cd /agent

python3 -c "
from src.memory import init_memory_manager

memory = init_memory_manager()
if memory:
    print('✅ Supermemory is ready!')
    print('   - Memory retrieval: Available')
    print('   - Memory storage: Available')
else:
    print('⚠️ Supermemory not configured (optional, agent will work without it)')
"
```

---

## Phase 6: Testing & Rollout

### Stage 1: Local Testing (30 minutes)

#### 1.1 Test Agent Locally

```bash
cd /agent

# Install dependencies
pip install -r requirements.txt

# Run agent in console mode
python src/main.py console
```

**What to expect:**
- Agent starts and prewarns plugins
- Console prompt appears
- You can type messages
- Agent responds with GPT-4o-mini

**Example interaction:**
```
User: Hello, how are you?
Agent: Hi! I'm doing great. I'm You+, your AI accountability assistant. How are you doing today?

User: I want to start exercising more
Agent: That's a wonderful goal! Tell me more about what kind of exercise interests you?
```

#### 1.2 Verify All Components

```python
# Create /agent/test_integration.py
import asyncio
import os
from dotenv import load_dotenv

load_dotenv()

async def test_all_components():
    """Test all components are working"""

    # Test 1: Configuration
    print("🔍 Testing Configuration...")
    from src.config import AgentConfig
    try:
        config = AgentConfig.from_env()
        print("   ✅ Configuration loaded")
    except ValueError as e:
        print(f"   ❌ Configuration error: {e}")
        return False

    # Test 2: Memory Manager
    print("🔍 Testing Memory Manager...")
    from src.memory import init_memory_manager
    memory = init_memory_manager()
    if memory:
        print("   ✅ Memory manager initialized")
    else:
        print("   ⚠️ Memory manager not configured (optional)")

    # Test 3: Conversation Manager
    print("🔍 Testing Conversation Manager...")
    from src.assistant import ConversationManager
    try:
        conv = ConversationManager(
            user_id="test_user",
            mood="supportive",
            memory_manager=memory
        )
        await conv.initialize()
        print("   ✅ Conversation manager ready")
    except Exception as e:
        print(f"   ❌ Conversation error: {e}")
        return False

    # Test 4: Models
    print("🔍 Testing AI Models...")
    try:
        from livekit.plugins import openai, cartesia, silero

        # Test LLM
        llm = openai.LLM.with_model(model="gpt-4o-mini")
        print("   ✅ GPT-4o-mini LLM ready")

        # Test STT
        stt = await cartesia.STT.create(
            api_key=os.getenv("CARTESIA_API_KEY"),
            model="ink"
        )
        print("   ✅ Cartesia Ink STT ready")

        # Test TTS
        tts = await cartesia.TTS.create(
            api_key=os.getenv("CARTESIA_API_KEY"),
            model="sonic-3"
        )
        print("   ✅ Cartesia Sonic-3 TTS ready")

        # Test VAD
        vad = silero.VAD.load()
        print("   ✅ Silero VAD ready")

    except Exception as e:
        print(f"   ❌ Model error: {e}")
        return False

    # Test 5: Post-call Processing
    print("🔍 Testing Post-Call Processing...")
    try:
        from src.post_call import PostCallProcessor
        processor = PostCallProcessor(memory)
        print("   ✅ Post-call processor ready")
    except Exception as e:
        print(f"   ❌ Post-call error: {e}")
        return False

    print("\n✅ All components verified successfully!")
    return True

if __name__ == "__main__":
    success = asyncio.run(test_all_components())
    exit(0 if success else 1)
```

Run the test:
```bash
python /agent/test_integration.py
```

### Stage 2: Backend Testing (20 minutes)

#### 2.1 Deploy Backend to Cloudflare

```bash
cd /be

# Install dependencies
npm install

# Build TypeScript
npm run build

# Deploy to Cloudflare Workers
wrangler deploy
```

#### 2.2 Test API Endpoints

**Test Token Generation:**
```bash
curl -X POST https://your-worker-url.workers.dev/api/call/initiate-livekit \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test-user-123",
    "callUUID": "call-uuid-456",
    "mood": "supportive"
  }'
```

**Expected response:**
```json
{
  "success": true,
  "data": {
    "roomName": "youplus-test-user-123-call-uuid-456",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600,
    "liveKitUrl": "wss://your-project.livekit.cloud"
  }
}
```

#### 2.3 Test Webhook Handler

```bash
# Send test webhook
curl -X POST https://your-worker-url.workers.dev/webhook/livekit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_livekit_api_secret" \
  -d '{
    "event": "room_finished",
    "room": {
      "name": "test-room",
      "sid": "room_sid_123",
      "num_participants": 2
    }
  }'
```

### Stage 3: iOS App Testing (30 minutes)

#### 3.1 Build and Run iOS App

```bash
# Open in Xcode
open swift/bigbruhh/BigBruhh.xcworkspace

# OR build from command line
xcodebuild -scheme BigBruhh -configuration Debug -derivedDataPath build
```

**Prerequisites:**
- Update LIVEKIT_URL in AppDelegate+LiveKit.swift
- Enable VoIP capabilities in Xcode
- Set bundle identifier
- Configure signing team

#### 3.2 Test VoIP Push Flow

**Setup:**
1. Simulator → Features → Location & Privacy → Disable location (if needed)
2. Build and run app
3. Grant VoIP push permissions when prompted

**Test steps:**
1. Phone rings → app receives VoIP push
2. Swipe up to answer
3. LiveKit connection established
4. Audio streaming works
5. Device tools respond (battery, flash, etc.)
6. Call ends → post-call processing triggered

#### 3.3 Manual Testing Checklist

- [ ] App launches without errors
- [ ] VoIP push received from backend
- [ ] Call screen appears
- [ ] Audio input/output working
- [ ] Microphone toggle works
- [ ] Speaker toggle works
- [ ] Device tools callable
  - [ ] Battery level displays
  - [ ] Flash screen flashes
  - [ ] Vibration triggers
- [ ] Call metadata sent to backend
- [ ] Call ends gracefully
- [ ] Post-call insights logged

### Stage 4: End-to-End Integration Test (60 minutes)

#### 4.1 Full Call Flow Test

**Setup:**
1. Agent running locally: `python /agent/src/main.py console`
2. Backend deployed to Cloudflare Workers
3. iOS app installed and running
4. LiveKit account configured
5. Supermemory account configured

**Test sequence:**

1. **Initiate call from iOS**
   - User taps "Call" button
   - iOS sends request to backend: POST `/api/call/initiate-livekit`
   - Backend returns: roomName, token, liveKitUrl
   - iOS stores in CallStateStore

2. **Connect to LiveKit room**
   - iOS creates WebRTC connection with token
   - Agent joins room automatically
   - Both establish WebRTC connection

3. **User speaks**
   - iOS captures audio, sends via WebRTC to agent
   - Agent receives via Cartesia STT (Ink)
   - Speech converted to text

4. **Agent processes**
   - STT output → GPT-4o-mini LLM
   - LLM considers Supermemory context (user's goals, promises)
   - LLM generates response
   - Response → Cartesia Sonic-3 TTS
   - Audio streamed back to iOS via WebRTC

5. **Device tools**
   - Agent says "Let me check your battery"
   - Agent calls `battery_level` tool
   - Tool executes on iOS, returns battery %
   - Agent says "Your battery is at 85%"

6. **Call ends**
   - User or agent ends call
   - Agent's `finally` block executes
   - Transcript extracted
   - Supermemory processes transcript
   - Insights extracted: promises, goals, sentiment
   - Data stored in Supermemory
   - Call metadata stored in database

#### 4.2 Performance Metrics to Track

**During call:**
- STT latency (target: < 100ms)
- LLM response time (target: < 500ms)
- TTS latency (target: < 200ms)
- End-to-end latency (target: < 800ms)
- Audio quality (mono/stereo, bitrate)

**After call:**
- Post-call processing time
- Supermemory storage success
- Database write success
- Transcript length
- Insights extraction accuracy

**Example metrics logging:**
```python
import time

class PerformanceTracker:
    def __init__(self):
        self.metrics = {}

    def start(self, metric_name: str):
        self.metrics[metric_name] = time.time()

    def end(self, metric_name: str) -> float:
        if metric_name not in self.metrics:
            return 0
        elapsed = time.time() - self.metrics[metric_name]
        print(f"⏱️ {metric_name}: {elapsed:.3f}s")
        return elapsed
```

### Stage 5: Production Deployment (varies)

#### 5.1 Agent Deployment

**Option A: Docker on Server**

```dockerfile
# /agent/Dockerfile (already created)
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src/ src/
COPY .env .env

CMD ["python", "src/main.py"]
```

Deploy:
```bash
cd /agent

# Build image
docker build -t youplus-agent:latest .

# Run container
docker run -d \
  --env-file .env \
  --name youplus-agent \
  youplus-agent:latest

# View logs
docker logs -f youplus-agent
```

**Option B: Fly.io Deployment**

```bash
cd /agent

# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Launch app
fly launch

# Deploy
fly deploy

# View logs
fly logs
```

**Option C: Railway Deployment**

```bash
cd /agent

# Push to GitHub
git push origin claude/elevenlabs-cartesia-livekit-migration-011CUuynu9j3QsQCVzyrEqtG

# Connect Railway to GitHub repo
# https://railway.app

# Railway auto-deploys on push
```

#### 5.2 Backend Deployment (Already on Cloudflare)

```bash
cd /be

# Deploy to production environment
wrangler deploy --env production

# Verify deployment
curl https://your-worker-url.workers.dev/health
```

#### 5.3 iOS App Deployment

1. **TestFlight Distribution:**
   - Archive app in Xcode
   - Upload to App Store Connect
   - Add testers
   - Send TestFlight link

2. **App Store Submission:**
   - Fill app information
   - Add screenshots and description
   - Submit for review
   - Wait for approval

#### 5.4 Database Migration

Run in your Supabase project:

```sql
-- From /be/sql/add-livekit-tables.sql
-- This creates all necessary tables
```

Then run data migration:

```bash
# In /be directory
npx ts-node scripts/migrate-to-supermemory.ts
```

---

## Monitoring & Optimization

### Key Metrics to Monitor

1. **Agent Health**
   - Uptime %
   - Error rate
   - Average response latency
   - Concurrent calls

2. **Call Quality**
   - Audio quality score (1-10)
   - Call completion rate %
   - User satisfaction (from feedback)
   - Device tool success rate %

3. **Supermemory Usage**
   - Memories stored per user
   - Average retrieval latency
   - Memory relevance score

4. **Cost**
   - LiveKit: per-minute pricing
   - Cartesia: per-minute STT/TTS
   - OpenAI: per-token LLM
   - Total monthly cost

### Logging Setup

Enable comprehensive logging:

```python
# In /agent/src/main.py
import logging
from pythonjsonlogger import jsonlogger

# JSON logging for production
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)

logger = logging.getLogger()
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)
```

### Alerting

Set up alerts for:
- Agent crashes or repeated errors
- High latency (> 2 seconds)
- Failed device tool executions
- Supermemory API failures
- High error rates (> 5%)

---

## Troubleshooting Production Issues

### Issue: Agent Not Responding

**Check:**
1. Agent process running: `ps aux | grep python`
2. LiveKit connection: logs should show room join
3. API keys valid: test manually
4. Network connectivity: ping LiveKit URL

**Fix:**
```bash
# Restart agent
docker restart youplus-agent

# Or on Fly.io
fly restart

# Check logs
docker logs youplus-agent
# or
fly logs
```

### Issue: High Latency

**Check:**
1. STT latency: Cartesia API status
2. LLM latency: OpenAI API status
3. TTS latency: Cartesia API status
4. Network latency: ping times

**Optimize:**
```python
# In config.py, adjust VAD settings
"aggressive": {
    "silence_duration_ms": 200,  # Respond faster
    "threshold": 0.4,
}
```

### Issue: Supermemory Failures

**Check:**
1. API key valid: test in dashboard
2. Rate limiting: check response headers
3. User exists: verify in Supermemory

**Graceful degradation:**
```python
# Memory failures don't crash agent
try:
    context = await memory.get_context_for_call(...)
except Exception as e:
    logger.warning(f"Memory retrieval failed: {e}")
    context = {}  # Continue without context
```

### Issue: iOS App Not Receiving Calls

**Check:**
1. VoIP push certificate valid
2. Device token registered
3. Backend sending correct payload
4. Firewall allowing WebRTC

**Test:**
```bash
# Send test push manually
# Use Apple's push notification tester
# Verify device token in backend
```

---

## Success Criteria

Your deployment is successful when:

✅ **Agent Testing:**
- [ ] Agent responds to text input locally
- [ ] All models initialize without errors
- [ ] Device tools execute successfully
- [ ] Post-call processing completes
- [ ] Supermemory integration works

✅ **Backend Testing:**
- [ ] Token generation endpoint works
- [ ] Webhook endpoint receives events
- [ ] Database updates on call end
- [ ] No 500 errors in logs

✅ **iOS Testing:**
- [ ] App builds without errors
- [ ] VoIP push received
- [ ] Audio stream establishes
- [ ] Call connects to agent
- [ ] Device tools respond
- [ ] Call completes cleanly

✅ **End-to-End Testing:**
- [ ] Full call flow works start to finish
- [ ] Supermemory stores insights
- [ ] Call metadata saved to database
- [ ] No crashes or errors
- [ ] Latency within targets

✅ **Production Ready:**
- [ ] Agent deployed and running
- [ ] Backend on Cloudflare Workers
- [ ] iOS app in TestFlight
- [ ] Monitoring and logging active
- [ ] Rollback plan documented

---

## Next Steps Summary

1. ✅ **Setup (< 15 minutes)**
   - [ ] Create LiveKit Cloud account
   - [ ] Create Supermemory account
   - [ ] Add credentials to `.env`

2. ✅ **Testing (< 2 hours)**
   - [ ] Run local agent test
   - [ ] Test all components
   - [ ] Deploy backend
   - [ ] Test iOS app
   - [ ] Full integration test

3. ✅ **Production (1-7 days)**
   - [ ] Deploy agent (Docker/Fly/Railway)
   - [ ] Configure monitoring
   - [ ] Deploy iOS app to TestFlight
   - [ ] Gather feedback
   - [ ] Iterate and optimize

4. ✅ **Scale (ongoing)**
   - [ ] Monitor metrics
   - [ ] Optimize latency
   - [ ] Expand to more users
   - [ ] Add new device tools
   - [ ] Improve prompts based on feedback

---

**You're 92% complete. The only thing between you and production is ~20 minutes of account setup and ~2 hours of testing!**

🚀 Get started with Phase 1.1 (LiveKit Cloud Setup) above.
