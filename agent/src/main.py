"""
LiveKit Agent for You+ - Core entrypoint
STT: Cartesia Ink
LLM: OpenAI GPT-4o-mini
TTS: Cartesia Sonic-3

Phase 3: Full integration with:
- Supermemory for context retrieval
- Device tools for iOS interaction
- Post-call processing
- Conversation personality management
"""

import os
import json
import logging
from datetime import datetime
from typing import Optional
from dotenv import load_dotenv

from livekit import agents
from livekit.agents import (
    AutoSubscribe,
    JobContext,
    WorkerOptions,
    llm,
    metrics,
)
from livekit.agents.pipeline import VoicePipelineAgent
from livekit.plugins import openai, cartesia, silero

# Import You+ modules
from memory import MemoryManager, init_memory_manager
from assistant import AssistantPersonality, ConversationManager
from tools import execute_device_tool
from post_call import PostCallProcessor

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Get configuration from environment
LIVEKIT_URL = os.getenv("LIVEKIT_URL")
LIVEKIT_API_KEY = os.getenv("LIVEKIT_API_KEY")
LIVEKIT_API_SECRET = os.getenv("LIVEKIT_API_SECRET")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
CARTESIA_API_KEY = os.getenv("CARTESIA_API_KEY")
SUPERMEMORY_API_KEY = os.getenv("SUPERMEMORY_API_KEY")

# Initialize memory manager (optional if SUPERMEMORY_API_KEY not set)
memory_manager: Optional[MemoryManager] = init_memory_manager()
post_call_processor: Optional[PostCallProcessor] = None


async def prewarm(proc: JobContext):
    """Prewarm plugins before agent starts"""
    logger.info("⏳ Prewarming plugins...")
    try:
        await openai.LLM.create()
        await cartesia.STT.create()
        await cartesia.TTS.create()
        logger.info("✅ Plugins prewarmed")
    except Exception as e:
        logger.error(f"❌ Plugin prewarm failed: {e}")


async def entrypoint(ctx: JobContext):
    """Main agent entrypoint - called when agent joins a room"""
    logger.info(f"📞 Agent joining room: {ctx.room.name}")

    # ============================================================================
    # 1. EXTRACT METADATA
    # ============================================================================

    room_metadata = ctx.room.metadata or {}
    user_id = room_metadata.get("user_id", "unknown")
    call_uuid = room_metadata.get("call_uuid", "unknown")
    mood = room_metadata.get("mood", "supportive")
    cartesia_voice_id = room_metadata.get("cartesia_voice_id", "default")
    supermemory_user_id = room_metadata.get("supermemory_user_id", user_id)

    logger.info(
        f"📊 Call metadata:"
        f"\n   User: {user_id}"
        f"\n   UUID: {call_uuid}"
        f"\n   Mood: {mood}"
        f"\n   Voice: {cartesia_voice_id}"
    )

    # ============================================================================
    # 2. INITIALIZE CONVERSATION MANAGER
    # ============================================================================

    conversation = ConversationManager(
        user_id=user_id,
        mood=mood,
        memory_manager=memory_manager,
    )

    # Load user context from Supermemory
    logger.info("📚 Loading user context from Supermemory...")
    await conversation.initialize()
    logger.info("✅ User context loaded")

    # ============================================================================
    # 3. INITIALIZE MODELS (STT, LLM, TTS)
    # ============================================================================

    logger.info("🤖 Initializing AI models...")

    # LLM (GPT-4o-mini)
    gpt_model = openai.LLM.with_model(model="gpt-4o-mini")

    # STT (Cartesia Ink)
    stt = await cartesia.STT.create(
        api_key=CARTESIA_API_KEY,
        model="ink",  # Cartesia Ink for accurate speech recognition
    )

    # TTS (Cartesia Sonic-3)
    tts = await cartesia.TTS.create(
        api_key=CARTESIA_API_KEY,
        model="sonic-3",  # Cartesia Sonic-3 for natural voice
        voice=cartesia_voice_id or "default",
    )

    # VAD (Voice Activity Detection)
    vad = silero.VAD.load()

    logger.info("✅ AI models initialized")

    # ============================================================================
    # 4. GET SYSTEM PROMPT WITH USER CONTEXT
    # ============================================================================

    system_prompt = conversation.get_system_prompt()
    logger.info(f"📝 System prompt loaded ({len(system_prompt)} chars)")

    # ============================================================================
    # 5. CREATE VOICE PIPELINE AGENT
    # ============================================================================

    logger.info("🎙️ Creating voice pipeline agent...")

    agent = VoicePipelineAgent(
        vad=vad,
        stt=stt,
        llm=gpt_model,
        tts=tts,
        chat_ctx=llm.ChatContext(
            messages=[
                llm.ChatMessage(
                    role="system",
                    content=system_prompt,
                )
            ]
        ),
    )

    # ============================================================================
    # 6. REGISTER DEVICE TOOLS
    # ============================================================================

    logger.info("🔧 Registering device tools...")

    # Device tools that can be called by the agent via data channel
    device_tools = {
        "get_battery_level": lambda params: execute_device_tool(
            "battery_level", params
        ),
        "flash_screen": lambda params: execute_device_tool(
            "flash_screen", params
        ),
        "vibrate": lambda params: execute_device_tool("vibrate", params),
        "get_location": lambda params: execute_device_tool(
            "get_location", params
        ),
        "capture_screenshot": lambda params: execute_device_tool(
            "capture_screenshot", params
        ),
    }

    # Register tools with agent
    for tool_name, tool_fn in device_tools.items():
        agent.add_tool(tool_name, tool_fn)
        logger.info(f"   ✓ Registered: {tool_name}")

    logger.info("✅ Device tools registered")

    # ============================================================================
    # 7. SETUP TRANSCRIPTION TRACKING
    # ============================================================================

    # Track conversation for post-call processing
    transcript_lines = []

    async def on_agent_message(message: str):
        """Called when agent sends message"""
        conversation.add_to_transcript("agent", message)
        transcript_lines.append(f"Agent: {message}")

    async def on_user_message(message: str):
        """Called when user sends message"""
        conversation.add_to_transcript("user", message)
        transcript_lines.append(f"User: {message}")

    # ============================================================================
    # 8. START AGENT
    # ============================================================================

    logger.info("🚀 Starting voice pipeline agent...")
    call_start_time = datetime.utcnow()

    try:
        await agent.start(ctx.room, ctx.participant)
        logger.info("✅ Agent started successfully")

    except Exception as e:
        logger.error(f"❌ Agent start failed: {e}")
        raise

    finally:
        # ========================================================================
        # 9. POST-CALL PROCESSING
        # ========================================================================

        call_end_time = datetime.utcnow()
        call_duration = (call_end_time - call_start_time).total_seconds()

        logger.info("📊 Call ended, starting post-call processing...")

        # Get transcript
        transcript = conversation.get_transcript()

        # Process transcript and extract insights
        if post_call_processor is None:
            post_call_processor = PostCallProcessor(memory_manager)

        insights = await post_call_processor.process_call_transcript(
            user_id=user_id,
            call_uuid=call_uuid,
            transcript=transcript,
            mood=mood,
        )

        # Store call metadata
        call_metadata = {
            "user_id": user_id,
            "call_uuid": call_uuid,
            "mood": mood,
            "duration_seconds": int(call_duration),
            "completion_status": "completed",
            "transcript_length": len(transcript),
            "insights": insights,
            "ended_at": call_end_time.isoformat(),
        }

        await post_call_processor.store_call_metadata(
            user_id=user_id,
            call_uuid=call_uuid,
            metadata=call_metadata,
        )

        logger.info("✅ Post-call processing complete")
        logger.info(
            f"   Duration: {call_duration:.1f}s"
            f"\n   Promises found: {len(insights.get('promises_made', []))}"
            f"\n   Goals mentioned: {len(insights.get('goals_mentioned', []))}"
            f"\n   Sentiment: {insights.get('sentiment', 'unknown')}"
        )


def create_agent_worker():
    """Create and configure the LiveKit agent worker"""
    worker = agents.Worker(
        prewarm_fnc=prewarm,
        entrypoint=entrypoint,
    )

    return worker


if __name__ == "__main__":
    logger.info("🚀 Starting You+ LiveKit Agent...")

    try:
        worker = create_agent_worker()

        worker_opts = WorkerOptions(
            api_connect_options=agents.APIConnectOptions(
                auto_subscribe=AutoSubscribe.SUBSCRIBE_ALL,
            ),
        )

        agents.run_app(worker)

    except Exception as e:
        logger.error(f"❌ Agent startup failed: {e}", exc_info=True)
        raise

