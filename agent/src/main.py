"""
LiveKit Agent for You+ - Core entrypoint
STT: Cartesia Ink
LLM: OpenAI GPT-4o-mini
TTS: Cartesia Sonic-3

Phase 3: Full integration with:
- Backend prompt-engine integration (Future You accountability system)
- Supermemory for context retrieval
- Device tools for iOS interaction
- Post-call processing
- Conversation personality management

PROMPT ENGINE INTEGRATION:
This agent receives prompts from the backend prompt-engine system (be/src/services/prompt-engine).
The backend generates sophisticated, personalized prompts including:
- System prompts with Future You personality, tone, guardrails, and tools
- First messages personalized based on user context and behavioral patterns
- Onboarding intelligence integration
- Behavioral pattern analysis

The agent extracts prompts from room metadata and uses them instead of generating its own.
If backend prompts are not available, it falls back to assistant.py generated prompts.
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

    # Parse room metadata (can be string or dict)
    room_metadata_raw = ctx.room.metadata or {}
    if isinstance(room_metadata_raw, str):
        try:
            room_metadata = json.loads(room_metadata_raw)
        except json.JSONDecodeError:
            logger.warning("Failed to parse room metadata as JSON, using empty dict")
            room_metadata = {}
    else:
        room_metadata = room_metadata_raw

    user_id = room_metadata.get("user_id") or room_metadata.get("userId", "unknown")
    call_uuid = room_metadata.get("call_uuid") or room_metadata.get("callUUID", "unknown")
    mood = room_metadata.get("mood", "supportive")
    cartesia_voice_id = room_metadata.get("cartesia_voice_id") or room_metadata.get("cartesiaVoiceId", "default")
    supermemory_user_id = room_metadata.get("supermemory_user_id") or room_metadata.get("supermemoryUserId", user_id)
    
    # Extract backend-generated prompts (from prompt-engine)
    prompts_data = room_metadata.get("prompts") or {}
    backend_system_prompt = prompts_data.get("systemPrompt") or prompts_data.get("system_prompt")
    backend_first_message = prompts_data.get("firstMessage") or prompts_data.get("first_message")

    logger.info(
        f"📊 Call metadata:"
        f"\n   User: {user_id}"
        f"\n   Supermemory User ID: {supermemory_user_id}"
        f"\n   UUID: {call_uuid}"
        f"\n   Mood: {mood}"
        f"\n   Voice: {cartesia_voice_id}"
        f"\n   Backend prompts: {'✅ Available' if backend_system_prompt else '❌ Missing - using fallback'}"
        f"\n   Supermemory: {'✅ Configured' if memory_manager else '❌ Not configured'}"
    )

    # ============================================================================
    # 2. LOAD SUPERMEMORY CONTEXT (CRITICAL FOR PERSONALIZATION)
    # ============================================================================

    supermemory_context = {}
    if memory_manager:
        logger.info(f"📚 Loading Supermemory context for user: {supermemory_user_id}")
        try:
            supermemory_context = await memory_manager.get_context_for_call(
                user_id=supermemory_user_id,
                mood=mood,
                max_memories=10,  # Get more memories for better context
            )
            logger.info(
                f"✅ Supermemory context loaded: "
                f"{len(supermemory_context.get('promises', []))} promises, "
                f"{len(supermemory_context.get('goals', []))} goals, "
                f"{len(supermemory_context.get('progress', []))} progress updates"
            )
        except Exception as e:
            logger.warning(f"⚠️ Failed to load Supermemory context: {e}")
            supermemory_context = {}
    else:
        logger.warning("⚠️ Supermemory not configured - memory features disabled")

    # ============================================================================
    # 3. INITIALIZE CONVERSATION MANAGER (for fallback/context)
    # ============================================================================

    conversation = ConversationManager(
        user_id=supermemory_user_id,  # Use Supermemory user ID
        mood=mood,
        memory_manager=memory_manager,
    )
    
    # Set the loaded context directly
    conversation.user_context = supermemory_context
    logger.info("✅ Conversation manager initialized with Supermemory context")

    # ============================================================================
    # 4. INITIALIZE AI MODELS (STT, LLM, TTS)
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
    # 5. GET SYSTEM PROMPT (Backend-generated + Supermemory enhancement)
    # ============================================================================

    # Use backend-generated prompt from prompt-engine if available
    # Otherwise fall back to assistant.py generated prompt
    if backend_system_prompt:
        system_prompt = backend_system_prompt
        logger.info(f"📝 Using backend-generated system prompt ({len(system_prompt)} chars)")
        logger.info("   Source: prompt-engine (Future You accountability system)")
        
        # ENHANCE with Supermemory context if available
        if supermemory_context and (supermemory_context.get('promises') or supermemory_context.get('goals')):
            supermemory_section = "\n\n## 🧠 SUPERMEMORY CONTEXT (Recent Memories)\n\n"
            
            if supermemory_context.get('promises'):
                supermemory_section += "**Recent Promises Made:**\n"
                for promise in supermemory_context['promises'][:5]:
                    supermemory_section += f"- {promise}\n"
                supermemory_section += "\n"
            
            if supermemory_context.get('goals'):
                supermemory_section += "**Current Goals:**\n"
                for goal in supermemory_context['goals'][:5]:
                    supermemory_section += f"- {goal}\n"
                supermemory_section += "\n"
            
            if supermemory_context.get('progress'):
                supermemory_section += "**Recent Progress:**\n"
                for progress in supermemory_context['progress'][:3]:
                    supermemory_section += f"- {progress}\n"
                supermemory_section += "\n"
            
            supermemory_section += "*Use this context to reference past conversations and track progress.*\n"
            system_prompt += supermemory_section
            logger.info("   ✅ Enhanced with Supermemory context")
    else:
        system_prompt = conversation.get_system_prompt()
        logger.info(f"📝 Using fallback system prompt ({len(system_prompt)} chars)")
        logger.warning("   ⚠️ Backend prompts not found - using basic assistant prompt")

    # ============================================================================
    # 6. CREATE VOICE PIPELINE AGENT
    # ============================================================================

    logger.info("🎙️ Creating voice pipeline agent...")

    # Build initial chat context with system prompt
    initial_messages = [
        llm.ChatMessage(
            role="system",
            content=system_prompt,
        )
    ]

    # Store first message for later use (will be spoken after agent starts)
    first_message_to_speak = backend_first_message

    if first_message_to_speak:
        logger.info(f"📢 First message ready: {first_message_to_speak[:50]}...")

    agent = VoicePipelineAgent(
        vad=vad,
        stt=stt,
        llm=gpt_model,
        tts=tts,
        chat_ctx=llm.ChatContext(
            messages=initial_messages
        ),
    )

    # ============================================================================
    # 7. REGISTER DEVICE TOOLS (Removed - Mock tools deleted)
    # ============================================================================
    
    # logger.info("🔧 Registering device tools...")
    # Device tools removed to eliminate bloat until WebRTC data channel is implemented

    # ============================================================================
    # 8. SETUP TRANSCRIPTION TRACKING
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
    # 9. START AGENT
    # ============================================================================

    logger.info("🚀 Starting voice pipeline agent...")
    call_start_time = datetime.utcnow()

    try:
        await agent.start(ctx.room, ctx.participant)
        logger.info("✅ Agent started successfully")
        
        # If backend provided first message, speak it immediately
        # This uses the backend-generated opening from prompt-engine
        if first_message_to_speak:
            logger.info("📢 Speaking backend-generated first message...")
            try:
                # Use the agent's say method to speak the first message
                # This ensures the backend-generated opening is used exactly as intended
                await agent.say(first_message_to_speak, allow_interruptions=True)
                logger.info("✅ First message spoken")
            except AttributeError:
                # Fallback: add to context and trigger generation
                logger.warning("agent.say() not available, using context approach")
                agent.chat_ctx.append(
                    llm.ChatMessage(role="assistant", content=first_message_to_speak)
                )
            except Exception as e:
                logger.warning(f"Could not speak first message: {e}, will use natural flow")

    except Exception as e:
        logger.error(f"❌ Agent start failed: {e}")
        raise

    finally:
        # ========================================================================
        # 10. POST-CALL PROCESSING (Store to Supermemory)
        # ========================================================================

        call_end_time = datetime.utcnow()
        call_duration = (call_end_time - call_start_time).total_seconds()

        logger.info("📊 Call ended, starting post-call processing...")

        # Get transcript
        transcript = conversation.get_transcript()

        # Process transcript and extract insights
        if post_call_processor is None:
            post_call_processor = PostCallProcessor(memory_manager)

        # Use Supermemory user ID for storing memories
        insights = await post_call_processor.process_call_transcript(
            user_id=supermemory_user_id,  # Use Supermemory user ID for consistency
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
            user_id=supermemory_user_id,  # Use Supermemory user ID
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

