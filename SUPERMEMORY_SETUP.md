# Supermemory Setup Guide

## Overview

Supermemory is a persistent memory system that allows the You+ agent to:
- **Retrieve** past promises, goals, and context
- **Store** call insights, progress, and commitment tracking
- **Personalize** conversations with user history
- **Learn** from past interactions

---

## Quick Start (5 minutes)

### Step 1: Create Supermemory Account

1. Go to **https://supermemory.ai**
2. Click **Sign Up**
3. Create account with email/password
4. Verify email

### Step 2: Get API Key

1. Log in to **https://supermemory.ai**
2. Go to **Settings** → **API Keys**
3. Click **Create New Key**
4. Copy the generated key (starts with `smem_`)

### Step 3: Configure in Agent

```bash
# In /agent/.env, add:
SUPERMEMORY_API_KEY=smem_your_key_here
SUPERMEMORY_BASE_URL=https://api.supermemory.ai
```

### Step 4: Verify Setup

```bash
cd /agent
python3 -c "
from src.memory import init_memory_manager
memory = init_memory_manager()
if memory:
    print('✅ Supermemory is ready!')
else:
    print('⚠️ Supermemory not configured')
"
```

---

## How It Works

### 1. On Call Start

```python
# Agent loads user context from Supermemory
context = await memory.get_context_for_call(
    user_id="user123",
    mood="supportive",
    max_memories=5
)

# Returns:
{
    "promises": ["Exercise 30 min daily", "Sleep by 11pm"],
    "goals": ["Get fit", "Better sleep schedule"],
    "progress": ["Exercised 4/7 days last week"],
    "raw_memories": [...]
}
```

**What happens:**
- Retrieves user's top 5 most relevant memories
- Filters by mood tags
- Enhances system prompt with personalized context
- Agent references this during conversation

### 2. During Call

Agent can reference memories:
- "How did exercising go last week?"
- "You mentioned wanting better sleep - how is that going?"
- "That aligns with your goal to get fit"

### 3. On Call End

```python
# Extract insights from transcript
insights = {
    "promises_made": ["Will exercise tomorrow"],
    "goals_mentioned": ["Run a 5K"],
    "blockers_identified": ["Work stress"],
    "progress_noted": ["2 weeks consistent"],
    "sentiment": "positive"
}

# Store to Supermemory
await memory.save_call_memory(
    user_id="user123",
    call_uuid="call-uuid",
    memory_data={
        "content": "Call Summary: User committed to exercise, mentioned work stress",
        "mood": "supportive",
        "insights": insights
    }
)
```

**What gets stored:**
- Structured call summary
- Extracted promises and goals
- Sentiment analysis
- Call metadata (duration, time, etc.)
- Full insights for future retrieval

---

## Supermemory Features

### 1. Memory Retrieval (Pre-Call)

```python
context = await memory.get_context_for_call(
    user_id="user123",
    mood="accountability",      # Filter by mood
    max_memories=5             # Top 5 memories
)
```

**Returns:**
- Previous promises and completion status
- User's stated goals
- Recent progress updates
- Raw memory objects

### 2. Memory Storage (Post-Call)

```python
await memory.save_call_memory(
    user_id="user123",
    call_uuid="call-uuid-123",
    memory_data={
        "content": "Summary text",
        "timestamp": "2024-01-08T15:30:00Z",
        "mood": "supportive",
        "insights": {
            "promises_made": [...],
            "goals_mentioned": [...],
        }
    }
)
```

**Tags automatically added:**
- `"promise"` - for commitments
- `"goal"` - for goals/aspirations
- `"progress"` - for completed actions
- `"onboarding"` - for initial profile data
- `"call"` - for all call-related memories
- `mood` value (e.g., `"supportive"`, `"accountability"`)
- `"processed"` - for analyzed content

### 3. Query Memories

Via Supermemory Dashboard:
1. Go to **https://supermemory.ai** → **Explore**
2. Search by tag: `promise`, `goal`, `progress`
3. Filter by user
4. View full memory history

---

## Integration Points in Code

### In `main.py`

```python
# 1. Initialize memory manager
memory_manager = init_memory_manager()

# 2. Load context for conversation
conversation = ConversationManager(
    user_id=user_id,
    mood=mood,
    memory_manager=memory_manager,  # Passes memory manager
)
await conversation.initialize()  # Loads context

# 3. Store call insights after call
processor = PostCallProcessor(memory_manager)  # Passes memory manager
insights = await processor.process_call_transcript(...)
```

### In `memory.py`

```python
class MemoryManager:
    # Retrieve context
    async def get_context_for_call(self, user_id, mood, max_memories)

    # Store call insights
    async def save_call_memory(self, user_id, call_uuid, memory_data)
```

### In `assistant.py`

```python
class ConversationManager:
    # Uses memory during initialization
    async def initialize(self):
        self.user_context = await self.memory_manager.get_context_for_call(...)

    # References in system prompt
    def get_system_prompt(self):
        # Includes user context in prompt
        return system_prompt_with_context
```

### In `post_call.py`

```python
class PostCallProcessor:
    # Processes and stores insights
    async def process_call_transcript(self, user_id, call_uuid, transcript):
        insights = {
            "promises_made": [...],
            "goals_mentioned": [...],
        }
        await self.memory_manager.save_call_memory(...)
```

---

## Data Model

### Memory Object Structure

```json
{
    "user_id": "user123",
    "content": "User promised to exercise 30 min daily",
    "tags": ["promise", "health", "supportive", "processed"],
    "metadata": {
        "call_uuid": "call-uuid-123",
        "created_at": "2024-01-08T15:30:00Z",
        "sentiment": "positive",
        "relevance": 0.95
    }
}
```

### Query Example

```python
# Get all promises made by user
# (via Supermemory dashboard or API)
GET /memories?user_id=user123&tags=promise

# Returns:
[
    {
        "id": "mem_xyz",
        "content": "I promise to exercise 30 minutes daily",
        "tags": ["promise", "health", "supportive"],
        "metadata": {...}
    },
    ...
]
```

---

## Best Practices

### 1. Memory Tagging

Use consistent tags for easy retrieval:
- `promise` - commitments/pledges
- `goal` - aspirations/targets
- `progress` - completed actions
- `blocker` - obstacles/challenges
- `mood_type` - `supportive`, `accountability`, `celebration`
- `processed` - AI-extracted data

### 2. Memory Freshness

- **Recent memories** (< 1 week) loaded by default
- **Top 5 memories** retrieved per call
- **Sentiment filtering** for mood-specific retrieval
- **Automatic cleanup** after 1 year (configurable)

### 3. Privacy & Security

- **User isolation** - users only see their own memories
- **Encryption** - data encrypted in transit and at rest
- **No audio storage** - only text summaries stored
- **GDPR compliance** - users can request deletion

---

## Troubleshooting

### Issue: "SUPERMEMORY_API_KEY not configured"

**Solution:**
1. Get key from supermemory.ai dashboard
2. Add to `.env`: `SUPERMEMORY_API_KEY=smem_...`
3. This is optional - agent works without it (just won't store memories)

### Issue: "Failed to retrieve context"

**Solution:**
1. Check API key is valid
2. Check network connectivity
3. Agent will continue without context (graceful degradation)

### Issue: "Memory too large"

**Solution:**
1. Summarize before storing (already done in post_call.py)
2. Limit stored memories to top insights only
3. Clean old memories via dashboard

### Issue: "User has no memories"

**Solution:**
This is normal for new users. Memories build up over time:
1. First call: onboarding data stored
2. Later calls: promises, goals, progress tracked
3. Agent can still operate without prior memories

---

## Testing

### Test 1: Verify Memory Manager

```python
from src.memory import init_memory_manager

memory = init_memory_manager()
assert memory is not None, "Memory manager failed to initialize"
print("✅ Memory manager ready")
```

### Test 2: Simulate Memory Retrieval

```python
import asyncio
from src.memory import init_memory_manager

async def test():
    memory = init_memory_manager()
    context = await memory.get_context_for_call(
        user_id="test_user_123",
        mood="supportive"
    )
    print(f"✅ Retrieved {len(context.get('promises', []))} promises")

asyncio.run(test())
```

### Test 3: Simulate Memory Storage

```python
import asyncio
from src.memory import init_memory_manager
from src.post_call import PostCallProcessor

async def test():
    memory = init_memory_manager()
    processor = PostCallProcessor(memory)

    insights = await processor.process_call_transcript(
        user_id="test_user_123",
        call_uuid="test_call_456",
        transcript="User: I'll exercise daily\nAgent: Great!",
        mood="supportive"
    )
    print(f"✅ Stored insights: {insights}")

asyncio.run(test())
```

---

## Advanced Configuration

### Custom Memory Filtering

```python
# Get only recent promises
context = await memory.get_context_for_call(
    user_id=user_id,
    mood="accountability",
    max_memories=10  # Get more memories
)
```

### Custom Tag Organization

```python
# Store with custom tags
await memory.save_call_memory(
    user_id=user_id,
    call_uuid=call_uuid,
    memory_data={
        "content": "...",
        "tags": ["promise", "health", "morning", "high-priority"],
        "metadata": {"priority": "high", "category": "health"}
    }
)
```

### Batch Memory Operations

```python
# In migration script (scripts/migrate-to-supermemory.ts)
# Batch import historical data
for user in active_users:
    await migrateUserToSupermemory(user.id)
```

---

## Resources

- **API Reference:** https://supermemory.ai/docs/api
- **Dashboard:** https://supermemory.ai/dashboard
- **Pricing:** https://supermemory.ai/pricing
- **Blog:** https://supermemory.ai/blog
- **Support:** support@supermemory.ai

---

## Next Steps

1. ✅ Understand how Supermemory works (this document)
2. 📝 Get API key from supermemory.ai
3. 🔧 Add to .env file
4. 🧪 Test with `python3 src/main.py console`
5. 📊 Monitor memories in Supermemory dashboard
6. 🚀 Deploy to production
