"""
LiveKit Agent for You+ - Core entrypoint
STT: Cartesia Ink
LLM: OpenAI GPT-4o-mini
TTS: Cartesia Sonic-3
"""

import os
import logging
from dotenv import load_dotenv
from livekit import agents
from livekit.agents import (
    AutoSubscribe,
    JobContext,
    WorkerOptions,
    llm,
)
from livekit.agents.pipeline import VoicePipelineAgent
from livekit.plugins import openai, cartesia

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


async def prewarm(proc: JobContext):
    """Prewarm plugins before agent starts"""
    await openai.LLM.create()
    await cartesia.STT.create()
    await cartesia.TTS.create()


async def entrypoint(ctx: JobContext):
    """Main agent entrypoint - called when agent joins a room"""
    logger.info(f"Agent joining room: {ctx.room.name}")

    # Extract metadata from room
    user_id = ctx.room.metadata.get("user_id", "unknown")
    mood = ctx.room.metadata.get("mood", "supportive")
    call_uuid = ctx.room.metadata.get("call_uuid", "unknown")

    logger.info(
        f"Call metadata - User: {user_id}, Mood: {mood}, UUID: {call_uuid}"
    )

    # Initialize LLM (GPT-4o-mini)
    gpt_model = openai.LLM.with_model(model="gpt-4o-mini")

    # Initialize STT (Cartesia Ink)
    stt = await cartesia.STT.create(
        api_key=CARTESIA_API_KEY,
        model="ink",  # Cartesia Ink for accurate speech recognition
    )

    # Initialize TTS (Cartesia Sonic-3)
    tts = await cartesia.TTS.create(
        api_key=CARTESIA_API_KEY,
        model="sonic-3",  # Cartesia Sonic-3 for natural voice
        voice=f"voice_{mood}",  # Voice will be selected based on mood
    )

    # System prompt for the agent
    system_prompt = """
    You are You+, a supportive AI accountability assistant designed to help users
    achieve their goals through personalized conversations and gentle accountability.

    Key traits:
    - Empathetic and understanding
    - Direct but kind feedback
    - Action-oriented advice
    - Remembers past conversations and user context

    Always:
    1. Ask clarifying questions
    2. Acknowledge emotions
    3. Provide actionable suggestions
    4. Follow up on previous commitments
    5. Celebrate progress
    """

    # Create voice pipeline agent
    agent = VoicePipelineAgent(
        vad=agents.SileroVADFactory.create_vad(),  # Using Silero VAD for now (research ongoing)
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

    # Subscribe to room events
    await agent.start(ctx.room, ctx.participant)

    # Log agent started
    logger.info(f"Agent started in room {ctx.room.name}")


if __name__ == "__main__":
    worker = agents.Worker(
        prewarm_fnc=prewarm,
        entrypoint=entrypoint,
    )

    # Build and run worker
    worker_opts = WorkerOptions(
        api_connect_options=agents.APIConnectOptions(
            auto_subscribe=AutoSubscribe.SUBSCRIBE_ALL,
        ),
    )

    agents.run_app(worker)
