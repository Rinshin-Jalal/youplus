# VAD (Voice Activity Detection) Research

## What is VAD?
Voice Activity Detection automatically detects when a user starts and stops speaking. It's crucial for:
- Natural turn-taking in conversations
- Reducing latency (agent responds when user finishes)
- Avoiding false triggers on background noise

---

## Available VAD Options for LiveKit Agents

### 1. **Silero VAD** (Default / Recommended)
**Status:** ✅ Built-in to LiveKit Agents
**Type:** On-device ML model (runs locally on CPU)
**Resource Usage:** Minimal - very lightweight
**Accuracy:** High
**Configuration Parameters:**
```python
min_speech_duration_ms: int = 100  # Minimum speech duration to start chunk
silence_duration_ms: int = 300     # Silence to wait after speech ends
speech_pad_ms: int = 30            # Padding before speech chunk
max_speech_buffer_s: int = 30      # Max duration to keep in buffer
threshold: float = 0.5             # 0-1 (higher = conservative, lower = sensitive)
```

**Pros:**
- Works offline
- No API calls needed
- Very fast
- Customizable sensitivity

**Cons:**
- Less context-aware than semantic approaches
- Might trigger on loud background noise
- Can't understand if user is mid-sentence

**Use Case:** General conversations, calls with clear audio

---

### 2. **OpenAI Realtime API's Server-Side VAD**
**Status:** ⚠️ Only available with OpenAI Realtime API (not with GPT-4o-mini)
**Type:** Server-side detection
**Configuration Parameters:**
```python
threshold: float          # Sensitivity (optional)
prefix_padding_ms: int    # Padding before detected speech
silence_duration_ms: int  # Silence to consider speech finished
```

**Pros:**
- Server-managed
- Tunable sensitivity
- Part of OpenAI's Realtime API ecosystem

**Cons:**
- Requires OpenAI Realtime API (we're using regular API)
- API calls for detection = latency
- Not applicable to our setup

---

### 3. **Semantic/Contextual Turn Detection**
**Status:** ⚠️ Research/Experimental
**Type:** LLM-based turn detection
**How it works:** Uses LLM to understand if user is done mid-thought

**Pros:**
- Won't interrupt mid-sentence
- Context-aware
- Better natural conversation flow

**Cons:**
- Adds latency (LLM inference)
- Can be slow
- More complex implementation
- Not built-in to LiveKit Agents framework

---

## Recommendation for You+

### Go with **Silero VAD** + Custom Tuning

**Why:**
1. ✅ Built-in to LiveKit Agents
2. ✅ No additional API calls or latency
3. ✅ Works offline
4. ✅ Proven accuracy for voice conversations
5. ✅ Customizable parameters

### Tuning for You+ Use Cases

For **accountability calls** (our main use case), we can tune Silero VAD:

```python
# Conservative (waits longer for user to finish)
VAD_CONFIG = {
    "silence_duration_ms": 500,      # Wait 500ms of silence
    "min_speech_duration_ms": 200,   # Require 200ms of speech
    "threshold": 0.6,                # Higher threshold = less noise sensitivity
    "speech_pad_ms": 50              # 50ms padding
}

# Aggressive (responds faster)
VAD_CONFIG = {
    "silence_duration_ms": 200,      # Wait 200ms of silence
    "min_speech_duration_ms": 50,    # Require 50ms of speech
    "threshold": 0.4,                # Lower threshold = more sensitive
    "speech_pad_ms": 30              # 30ms padding
}
```

### Recommended for You+: Conservative + Semantic Fallback

Start with **Conservative Silero VAD**, and monitor:
- If users are interrupted mid-sentence → increase `silence_duration_ms`
- If background noise triggers detection → increase `threshold`
- If agent doesn't respond → decrease `min_speech_duration_ms`

---

## Alternative: Hybrid Approach

Combine Silero VAD with **turn detection heuristics**:
1. Use Silero for raw voice detection
2. Add semantic turn detection using LLM after transcription
3. Example: If transcript ends with "?" or "because" → wait longer

This requires custom logic but provides best of both worlds.

---

## Next Steps

1. Start with default Silero VAD
2. Test with real users
3. Collect metrics:
   - % of calls where user was interrupted
   - % of calls with false positives (noise)
   - Average response latency
4. Adjust parameters based on data
5. Consider semantic VAD implementation if needed

---

## Implementation

Current `main.py` uses:
```python
vad=agents.SileroVADFactory.create_vad()
```

To add custom parameters:
```python
from livekit.plugins import silero

vad = silero.VAD.load(
    min_speech_duration_ms=100,
    silence_duration_ms=300,
    speech_pad_ms=30,
    max_speech_buffer_s=30,
    threshold=0.5
)
```

This can be configured in `config.py` or environment variables.
