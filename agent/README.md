# You+ LiveKit Agent

## Overview

A Python-based AI accountability assistant that runs on LiveKit infrastructure. The agent uses:
- **STT**: Cartesia Ink (speech recognition)
- **LLM**: OpenAI GPT-4o-mini (conversation)
- **TTS**: Cartesia Sonic-3 (voice generation)
- **Memory**: Supermemory API (user context)
- **VAD**: Silero VAD (voice activity detection)

## Architecture

```
User (iOS)
    ↓ [WebRTC Audio]
LiveKit Room
    ↓
Python Agent
    ├─→ Cartesia Ink (STT)
    ├─→ GPT-4o-mini (LLM)
    ├─→ Cartesia Sonic-3 (TTS)
    ├─→ Supermemory (Context)
    └─→ Device Tools (Data Channel)
```

## Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Environment

Create a `.env` file with:

```env
# LiveKit
LIVEKIT_URL=wss://your-livekit-url
LIVEKIT_API_KEY=your-api-key
LIVEKIT_API_SECRET=your-api-secret

# Cartesia (STT + TTS)
CARTESIA_API_KEY=your-cartesia-key
CARTESIA_STT_MODEL=ink
CARTESIA_TTS_MODEL=sonic-3

# OpenAI (LLM)
OPENAI_API_KEY=sk-your-openai-key
OPENAI_MODEL=gpt-4o-mini

# Supermemory (Optional - for context retrieval)
SUPERMEMORY_API_KEY=your-supermemory-key
SUPERMEMORY_BASE_URL=https://api.supermemory.ai
```

### 3. Run Agent

```bash
# Test locally
python src/main.py console

# Run as LiveKit worker
python src/main.py
```

## Module Structure

### Core Modules

| Module | Purpose |
|--------|---------|
| `main.py` | Agent entrypoint, orchestration |
| `config.py` | Configuration management |
| `memory.py` | Supermemory integration |
| `assistant.py` | Personality & conversation logic |
| `tools.py` | Device tool execution |
| `post_call.py` | Post-call processing |

### Flow

```
Agent Join
    ↓
Load Config → Load User Context → Initialize Models
    ↓
Register Device Tools
    ↓
Start Voice Pipeline (STT → LLM → TTS)
    ↓
User Speaks → STT → LLM → TTS → Agent Speaks
    ↓
Track Transcript
    ↓
Call Ends
    ↓
Process Transcript → Extract Insights → Save to Supermemory
```

## Features

### 1. Multi-Mood Support

Agent personality adapts based on call mood:

- **Supportive**: Empathetic, encouraging approach
- **Accountability**: Direct, action-oriented feedback
- **Celebration**: Enthusiastic, progress-focused

### 2. Supermemory Integration

- Retrieves user's past promises, goals, and progress
- Enhances system prompt with personalized context
- Stores call insights for future reference
- Tracks call history and metrics

### 3. Device Tools

Agent can request device actions via data channel:

```python
# Example: Agent can ask for battery status
"What's your battery level?"
→ Sends: {"tool": "battery_level"}
→ iOS responds with: {"battery": 87, "charging": false}
```

Available tools:
- `battery_level`: Get device battery status
- `flash_screen`: Flash screen to grab attention
- `vibrate`: Vibrate device
- `get_location`: Get device location (with permission)
- `capture_screenshot`: Capture screen context

### 4. Post-Call Processing

After call ends:
- ✅ Extract promises and commitments
- ✅ Identify goals mentioned
- ✅ Detect blockers/challenges
- ✅ Analyze sentiment
- ✅ Store to Supermemory
- ✅ Generate call summary

### 5. Voice Activity Detection (VAD)

Customizable VAD behavior:

```python
# Conservative (wait longer for user to finish)
VAD: min_speech=200ms, silence=500ms, threshold=0.6

# Balanced (default)
VAD: min_speech=100ms, silence=300ms, threshold=0.5

# Aggressive (respond faster)
VAD: min_speech=50ms, silence=200ms, threshold=0.4
```

## Configuration

### Via Environment Variables

```bash
# VAD mode
AGENT_VAD_MODE=balanced  # conservative, balanced, aggressive

# Personality
AGENT_PERSONALITY=supportive  # supportive, accountability, celebration

# Logging
LOG_LEVEL=INFO  # DEBUG, INFO, WARNING, ERROR
```

### Via Code (config.py)

```python
from config import AgentConfig, get_vad_config, get_personality_prompt

# Load config
config = AgentConfig.from_env()

# Get VAD settings
vad_config = get_vad_config("conservative")

# Get personality
prompt = get_personality_prompt("supportive")
```

## Deployment

### Docker

```bash
# Build
docker build -t youplus-agent .

# Run
docker run -e LIVEKIT_URL=... \
           -e LIVEKIT_API_KEY=... \
           -e CARTESIA_API_KEY=... \
           youplus-agent
```

### Fly.io

```bash
# Deploy
flyctl launch
flyctl deploy

# Monitor logs
flyctl logs
```

### Railway

```bash
# Connect GitHub repo
# Set environment variables in dashboard
# Auto-deploys on push to main
```

## Testing

### Unit Tests

```bash
pytest tests/
```

### Integration Tests

```bash
# Test with local LiveKit
python src/main.py console

# Test with live LiveKit Cloud
python src/main.py
```

### Manual Testing

```python
# Test config loading
from config import AgentConfig
config = AgentConfig.from_env()
print(f"✅ Config loaded: {config}")

# Test memory manager
from memory import init_memory_manager
memory = init_memory_manager()
context = await memory.get_context_for_call("user_id")
print(f"✅ Context loaded: {context}")

# Test post-call processing
from post_call import PostCallProcessor
processor = PostCallProcessor(memory)
insights = await processor.process_call_transcript(
    user_id="user_id",
    call_uuid="call_uuid",
    transcript="User: Hello\nAgent: Hi there!",
    mood="supportive"
)
print(f"✅ Insights: {insights}")
```

## Monitoring

### Metrics to Track

- Call connection time
- STT latency (speech → text)
- LLM latency (response generation)
- TTS latency (text → speech)
- End-to-end latency (user speech → agent speech)
- Call completion rate
- Promise extraction accuracy
- Supermemory API latency

### Logs

```bash
# Real-time logs
tail -f /var/log/youplus-agent.log

# Debug level
LOG_LEVEL=DEBUG python src/main.py

# Filter by module
grep "memory.py" /var/log/youplus-agent.log
```

## Troubleshooting

### Issue: "LIVEKIT_URL not set"

**Solution**: Check `.env` file or set environment variable:
```bash
export LIVEKIT_URL=wss://your-livekit-url
```

### Issue: "Cartesia API key invalid"

**Solution**: Verify API key from cartesia.ai dashboard:
```bash
export CARTESIA_API_KEY=your-valid-key
```

### Issue: "Supermemory context failed"

**Solution**: Check if API key is set. Memory is optional:
```bash
# Works fine without Supermemory
unset SUPERMEMORY_API_KEY
```

### Issue: "Agent not responding"

**Solution**: Check VAD settings - might be too conservative:
```python
# Switch to balanced VAD
vad_config = get_vad_config("balanced")
```

### Issue: "Device tool call failed"

**Solution**: Ensure iOS app is sending tool responses via data channel

## Performance Tuning

### For Low Latency

```python
# Use aggressive VAD
VAD mode: aggressive

# Reduce model precision
Model: gpt-3.5-turbo (faster than gpt-4o-mini)

# Simpler TTS
Voice: standard (not premium)
```

### For Better Quality

```python
# Use conservative VAD
VAD mode: conservative

# Use better models
Model: gpt-4o-mini (or gpt-4o)
Voice: premium Cartesia voice

# Enable context
SUPERMEMORY_API_KEY: enabled
```

## Security

### Secrets Management

```bash
# Use environment files (not committed)
export $(cat .env.local | xargs)

# Or use secrets manager
export LIVEKIT_API_SECRET=$(aws secretsmanager get-secret-value ...)
```

### Data Privacy

- Transcripts stored temporarily only
- Audio not logged (only URLs stored)
- Supermemory handles user data per their privacy policy
- No personal data logged to stdout

## Contributing

1. Create feature branch
2. Add tests for new features
3. Ensure logs use appropriate levels
4. Update README with new features
5. Submit PR

## References

- [LiveKit Agents Docs](https://docs.livekit.io/agents/)
- [Cartesia API Docs](https://cartesia.ai/docs)
- [OpenAI API Reference](https://platform.openai.com/docs/)
- [Supermemory API](https://supermemory.ai/)

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review logs with `LOG_LEVEL=DEBUG`
3. Open GitHub issue with:
   - Error message
   - Environment (Fly.io, Railway, Docker, etc.)
   - Reproduction steps
