# Memory & Pattern Detection Feature

**Complete guide to vector embeddings, semantic search, and behavioral pattern analysis.**

---

## 🎯 What is Memory?

Memory is the **pattern detection system** that uses OpenAI embeddings to find recurring behaviors, excuse patterns, and breakthrough moments. It converts excuses, promises, and call transcripts into vectors, enabling semantic similarity search.

Think of it as the system's ability to recognize "You've said this before" even when words are different but meaning is the same.

---

## 📊 Database: `memory_embeddings` Table

**Key fields**:
- `text_content`: Original text (excuse, quote, observation)
- `embedding`: 1536-dimensional vector from OpenAI
- `content_type`: excuse/craving/demon/echo/pattern/breakthrough
- `source_id`: Links to promise/call that generated it
- `metadata`: JSONB with context (frequency, dates, etc.)

**References**:
- Type definition: [be/src/types/database.ts:197-206](../../be/src/types/database.ts#L197)
- Full schema: [DATABASE.md - Table 7](../DATABASE.md#table-7-memory_embeddings)

---

## 🏗️ How Memory is Created

### Automatic Memory Creation

**Triggers**:
1. Promise marked as broken (excuse extracted)
2. Call transcript analyzed (patterns detected)
3. User mentions craving/temptation
4. Breakthrough moment identified
5. Recurring phrase detected (echo)

### Process: Excuse → Embedding

**Most common**: When promise broken with excuse

**Flow**:
```
Evening call happens
  ↓
User: "I couldn't workout because I was too tired"
  ↓
AI marks promise broken
  ↓
Excuse saved: "I was too tired"
  ↓
Backend receives webhook
  ↓
Memory ingestion service triggered
  ↓
Extract excuse text
  ↓
Send to OpenAI Embeddings API
  ↓
Receive 1536-dimensional vector
  ↓
Save to memory_embeddings table
```

**Memory Ingestion Service**: [be/src/services/memory-ingestion-service.ts](../../be/src/services/memory-ingestion-service.ts)

### OpenAI Embedding Generation

**API call**:
```
POST https://api.openai.com/v1/embeddings
{
  "model": "text-embedding-ada-002",
  "input": "I was too tired"
}
```

**Response**:
```json
{
  "data": [{
    "embedding": [0.0023, -0.0098, 0.0234, ... 1536 numbers],
    "index": 0
  }],
  "model": "text-embedding-ada-002",
  "usage": { "total_tokens": 5 }
}
```

**What is an embedding?**:
- Vector (array of numbers) representing semantic meaning
- Similar meanings = similar vectors
- "I was tired" and "Too exhausted" = close vectors
- "I was tired" and "Traffic was bad" = distant vectors

**Why 1536 dimensions**: OpenAI's model standard, captures nuanced meaning.

### Record Created

**In memory_embeddings table**:
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "source_id": "promise_uuid",
  "content_type": "excuse",
  "text_content": "I was too tired",
  "embedding": [0.0023, -0.0098, ... 1536 numbers],
  "metadata": {
    "source_table": "promises",
    "promise_date": "2024-01-15",
    "call_id": "call_uuid",
    "frequency_count": 1,
    "first_occurrence": "2024-01-15",
    "context": "Broke workout promise"
  },
  "created_at": "2024-01-15T20:35:00Z"
}
```

---

## 🔍 Content Types Explained

### 1. Excuse
**Source**: Promise excuse_text when broken
**Example**: "I was too tired to workout"
**Purpose**: Track rationalization patterns
**Usage**: "You've used this excuse 5 times"

### 2. Craving
**Source**: Call transcript mentions of temptation
**Example**: "I really wanted to scroll my phone"
**Purpose**: Identify trigger moments
**Usage**: "Phone is your most common craving"

### 3. Demon
**Source**: Negative self-talk in transcripts
**Example**: "I'm not good enough anyway"
**Purpose**: Track limiting beliefs
**Usage**: "You keep saying you're not good enough"

### 4. Echo
**Source**: Repeated phrases across calls
**Example**: "I'll start tomorrow" (said 5+ times)
**Purpose**: Catch procrastination patterns
**Usage**: "That's the 7th time you've said that"

### 5. Pattern
**Source**: Behavioral observations by AI
**Example**: "Always quits after 3 days"
**Purpose**: Meta-level behavior tracking
**Usage**: "Your 3-day pattern is showing again"

### 6. Breakthrough
**Source**: Positive moments in transcripts
**Example**: "I did it without making excuses"
**Purpose**: Celebrate growth, build on success
**Usage**: "Remember when you overcame this?"

---

## 🔄 How Memory Can Be Updated

### Frequency Tracking

When same excuse appears again:
```
New excuse: "I was exhausted"
  ↓
Create embedding
  ↓
Search for similar embeddings (cosine similarity)
  ↓
Found match: "I was too tired" (similarity > 0.9)
  ↓
Update metadata:
  frequency_count: 1 → 2
  last_occurrence: today
  ↓
Don't create duplicate embedding
```

**Why**: One embedding per semantic meaning, track frequency in metadata.

### Manual Deletion (Support)

If memory incorrectly categorized:
- Support can delete embedding
- Re-create with correct content_type
- Adjust metadata

**Rare**: System is accurate, manual edits uncommon.

### Bulk Re-embedding (Admin)

If OpenAI model improves:
- Admin can trigger re-embedding
- Fetch all text_content
- Generate new embeddings
- Replace old vectors

**Future feature**: Not currently implemented.

---

## 🎯 How Memory is Used

### Backend Usage

#### 1. **Semantic Search During Calls**
**Tool**: [be/src/routes/tool-handlers/searchMemories.ts](../../be/src/routes/tool-handlers/searchMemories.ts)

**AI conversation**:
```
User: "I couldn't do it because I was drained"
  ↓
AI calls searchMemories("I was drained")
  ↓
Backend:
  1. Create embedding for query
  2. Calculate cosine similarity with all user's embeddings
  3. Return top 5 matches
  ↓
AI receives:
  - "I was too tired" (0.95 similarity)
  - "I was exhausted" (0.93 similarity)
  - "No energy left" (0.89 similarity)
  ↓
AI: "You've used this excuse 3 times this month.
     Last time was January 10th.
     Same pattern every Monday."
```

**Cosine similarity**:
- Measures angle between vectors
- 1.0 = identical meaning
- 0.9+ = very similar
- 0.7-0.9 = related
- <0.7 = different

#### 2. **Excuse Pattern Analysis**
**Tool**: [be/src/routes/tool-handlers/analyzeExcusePattern.ts](../../be/src/routes/tool-handlers/analyzeExcusePattern.ts)

**Process**:
```
AI calls analyzeExcusePattern()
  ↓
Backend:
  1. Fetch all user's excuse embeddings
  2. Cluster similar excuses (k-means clustering)
  3. Count frequency per cluster
  4. Identify dominant patterns
  ↓
Returns:
  [
    {
      "theme": "Energy/Fatigue",
      "examples": ["too tired", "exhausted", "no energy"],
      "frequency": 12,
      "percentage": 40%
    },
    {
      "theme": "Time Pressure",
      "examples": ["too busy", "no time", "schedule conflict"],
      "frequency": 8,
      "percentage": 27%
    }
  ]
  ↓
AI: "40% of your excuses are about being tired.
     That's your primary escape route."
```

**Clustering**: Groups semantically similar excuses automatically.

#### 3. **Breakthrough Moment Reference**
**Tool**: [be/src/routes/tool-handlers/detectBreakthroughMoments.ts](../../be/src/routes/tool-handlers/detectBreakthroughMoments.ts)

**Usage**:
```
User struggling with promise
  ↓
AI calls detectBreakthroughMoments()
  ↓
Backend finds embeddings with content_type="breakthrough"
  ↓
Returns moments where user succeeded despite difficulty
  ↓
AI: "Remember January 5th? You said 'I did it without excuses'
     You overcame this before. Do it again."
```

**Motivation**: Reference past success to build confidence.

#### 4. **Behavioral Pattern Detection**
**Service**: [be/src/services/embedding-services/behavioral.ts](../../be/src/services/embedding-services/behavioral.ts)

**Nightly analysis** (runs at 2am UTC):
```
For each user:
  ↓
Fetch last 30 days of embeddings
  ↓
Analyze patterns:
  - Excuse frequency trends
  - Emerging new excuses
  - Declining old excuses
  - Day-of-week patterns
  - Time-of-day patterns
  ↓
Store insights in identity_status.memory_insights
```

**Example insights**:
```json
{
  "countsByType": {
    "excuse": 45,
    "breakthrough": 3,
    "craving": 12
  },
  "topExcuseCount7d": 8,
  "emergingPatterns": [
    {
      "sampleText": "Work stress overwhelming",
      "recentCount": 5,
      "baselineCount": 0,
      "growthFactor": 5.0
    }
  ]
}
```

**Action**: AI adjusts next call based on insights.

#### 5. **Brutal Reality Input**
**Service**: [be/src/services/brutal-reality-engine.ts](../../be/src/services/brutal-reality-engine.ts)

Daily review references memory:
```
Fetch excuse patterns
  ↓
Include in brutal reality review:
  "Your top excuse: 'I was too tired' (12 times this month)
   That's not a reason, that's a habit.
   Your breakthrough moment was 3 weeks ago.
   You've regressed since then."
```

### Frontend (iOS) Usage

#### 1. **Pattern Visualization**
Shows excuse clusters:
- Pie chart of excuse themes
- Top 3 excuses with frequency
- Emerging patterns highlighted
- Timeline of excuse evolution

#### 2. **Insight Cards**
Home screen cards:
```
💡 Pattern Detected
"You've used 'too tired' 5 times this month.
Monday is your weakest day."
```

#### 3. **Breakthrough Timeline**
Shows positive moments:
- Date of breakthrough
- What they said
- Context (which promise)
- Can tap to review full call

#### 4. **Excuse History**
In promise detail view:
- Shows all times similar excuse used
- Dates and promises affected
- Pattern visualization

---

## 🔍 Semantic Search Explained

### How Similarity Works

**Example**:
```
Query: "I was drained"

Embeddings in database:
1. "I was too tired" → similarity: 0.95 (very close)
2. "No energy left" → similarity: 0.91 (very close)
3. "Traffic was bad" → similarity: 0.23 (unrelated)
4. "I went to the gym" → similarity: 0.15 (unrelated)
```

**AI sees**:
- Top 2 results are semantically similar
- Can say "You've used this excuse before"
- Even though words are different

**vs Traditional Search**:
- SQL: "I was drained" ≠ "I was tired" (no match)
- Embedding: "I was drained" ≈ "I was tired" (similar meaning)

### Query Examples

**User says**: "I didn't have time"
**Semantic matches**:
- "I was too busy" (0.93)
- "Schedule was packed" (0.89)
- "No time available" (0.95)

**User says**: "I felt lazy"
**Semantic matches**:
- "Didn't feel motivated" (0.91)
- "Just wasn't in the mood" (0.87)
- "Lacked drive" (0.89)

**Power**: Catches excuse patterns even when user varies language.

---

## 🤔 Design Decisions

### Why Vector Embeddings (Not Keyword Matching)?

**Problem with keywords**:
```
User says: "I was exhausted"
System searches for: "I was exhausted"
Doesn't find: "I was too tired"
❌ Misses the pattern
```

**Solution with embeddings**:
```
User says: "I was exhausted"
System finds: "I was too tired" (0.93 similar)
✅ Catches the pattern
```

**Benefits**:
- Language-agnostic pattern detection
- Handles synonyms automatically
- Works with paraphrasing
- Captures semantic meaning

### Why OpenAI (Not Custom Model)?

**Quality**:
- OpenAI embeddings are state-of-art
- Pre-trained on massive text corpus
- Understands nuanced language

**Cost**:
- Very cheap ($0.0001 per 1K tokens)
- One-time cost per text
- Store vector forever

**Simplicity**:
- No model training needed
- No infrastructure for ML
- Just API call

**Trade-off**: Dependency on OpenAI service.

### Why Store Embeddings (Not Generate On-Demand)?

**Speed**:
- Pre-computed vectors = instant search
- On-demand = 100ms+ per query
- Calls need real-time responses

**Cost**:
- Generate once, use forever
- On-demand = pay per search
- Searches happen frequently

**Consistency**:
- Same embedding for same text
- On-demand might drift over time

**Trade-off**: Database storage (but vectors compress well).

### Why Track Frequency in Metadata?

**Efficiency**:
- One embedding per unique excuse
- Frequency tracked separately
- No duplicate vectors

**Performance**:
- Fewer vectors = faster search
- Cleaner clustering

**Insights**:
- Can say "You've said this 12 times"
- Track excuse evolution over time

---

## 📊 Memory Lifecycle Example

### Day 1: First Excuse
```
User breaks promise
  ↓
Excuse: "I was too tired"
  ↓
Create embedding
  ↓
Stored with metadata:
  frequency_count: 1
  first_occurrence: 2024-01-15
```

### Day 5: Similar Excuse
```
User breaks promise
  ↓
Excuse: "I was exhausted"
  ↓
Create embedding
  ↓
Search for similar
  ↓
Found: "I was too tired" (0.94 similar)
  ↓
Update existing:
  frequency_count: 2
  last_occurrence: 2024-01-19
  ↓
During call:
AI: "You said this on January 15th too."
```

### Day 12: Pattern Detected
```
User breaks promise
  ↓
Excuse: "No energy today"
  ↓
Search shows 3 similar excuses
  ↓
AI calls analyzeExcusePattern()
  ↓
Backend clusters:
  Theme: "Energy/Fatigue"
  Examples: ["too tired", "exhausted", "no energy"]
  Frequency: 3 times in 12 days
  ↓
AI: "25% of your broken promises use energy excuses.
     That's becoming your pattern."
```

### Day 30: Breakthrough
```
User keeps difficult promise
  ↓
AI: "How did you do it today?"
User: "I just did it without making excuses"
  ↓
AI detects positive moment
  ↓
Create embedding:
  content_type: "breakthrough"
  text_content: "I just did it without making excuses"
  ↓
Later references:
AI: "Remember day 30? You can do this."
```

---

## 🔬 Pattern Detection in Action

### Excuse Clustering Example

**User's excuses over 30 days**:
```
Day 1: "I was too tired"
Day 3: "No time in the morning"
Day 5: "I was exhausted"
Day 8: "Schedule was packed"
Day 12: "No energy left"
Day 15: "Too busy at work"
Day 18: "I was drained"
Day 22: "Ran out of time"
Day 25: "I was worn out"
```

**Clustering result**:
```
Cluster 1: Energy/Fatigue (55%)
  - "I was too tired"
  - "I was exhausted"
  - "No energy left"
  - "I was drained"
  - "I was worn out"

Cluster 2: Time Pressure (45%)
  - "No time in the morning"
  - "Schedule was packed"
  - "Too busy at work"
  - "Ran out of time"
```

**AI uses this**:
```
AI: "Mike, I've analyzed your excuses.
    55% are about being tired.
    45% are about time.

    Let's address the tired excuse.
    What time are you going to bed?

    [Digs into root cause]"
```

---

## 📁 Key File References

### Backend
- Memory ingestion: [be/src/services/memory-ingestion-service.ts](../../be/src/services/memory-ingestion-service.ts)
- Embedding services: [be/src/services/embedding-services/](../../be/src/services/embedding-services/)
  - Core: [core.ts](../../be/src/services/embedding-services/core.ts)
  - Behavioral: [behavioral.ts](../../be/src/services/embedding-services/behavioral.ts)
  - Patterns: [patterns.ts](../../be/src/services/embedding-services/patterns.ts)
- Search tool: [be/src/routes/tool-handlers/searchMemories.ts](../../be/src/routes/tool-handlers/searchMemories.ts)
- Pattern analysis: [be/src/routes/tool-handlers/analyzeExcusePattern.ts](../../be/src/routes/tool-handlers/analyzeExcusePattern.ts)
- Type definitions: [be/src/types/database.ts:197-206](../../be/src/types/database.ts#L197)

### Frontend (iOS)
- Pattern visualization: (Future implementation)
- Insight cards: (Future implementation)

### Related Documentation
- Promises (excuse source): [PROMISES.md](PROMISES.md)
- Calls (pattern detection): [CALLS.md](CALLS.md)
- Database schema: [DATABASE.md](../DATABASE.md)

---

## 🎓 Common Questions

**Q: Can I delete my memory embeddings?**
A: Not directly via app. Pattern detection is core to accountability. Support can delete if truly needed.

**Q: Does AI share my embeddings with others?**
A: No. Each user's embeddings are private. Completely isolated per user.

**Q: What if I genuinely have different excuses?**
A: System knows difference between similar (pattern) and unique (legitimate). Looks at semantic meaning.

**Q: Can I see my excuse patterns?**
A: Yes, pattern visualization planned for frontend. Currently AI references during calls.

**Q: How accurate is pattern detection?**
A: Very accurate. 0.9+ similarity threshold means near-identical meaning. False positives rare.

**Q: Does this use a lot of storage?**
A: No. Each embedding is ~6KB. 100 excuses = 600KB total. Minimal.

**Q: What if OpenAI API is down?**
A: Pattern detection pauses. Existing embeddings still searchable. New excuses queued for later processing.

---

*Last updated: 2025-01-11*
