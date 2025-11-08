"""
Configuration for You+ LiveKit Agent
Centralized settings for STT, LLM, TTS, and integrations
"""

import os
from typing import Optional
from dataclasses import dataclass


@dataclass
class LiveKitConfig:
    """LiveKit Cloud configuration"""
    url: str
    api_key: str
    api_secret: str


@dataclass
class CartesiaConfig:
    """Cartesia STT/TTS configuration"""
    api_key: str
    stt_model: str = "ink"  # Cartesia Ink for STT
    tts_model: str = "sonic-3"  # Cartesia Sonic-3 for TTS
    default_voice: str = "default"


@dataclass
class OpenAIConfig:
    """OpenAI LLM configuration"""
    api_key: str
    model: str = "gpt-4o-mini"


@dataclass
class SuprememoryConfig:
    """Supermemory integration configuration"""
    api_key: Optional[str]
    base_url: str = "https://api.supermemory.ai"


@dataclass
class AgentConfig:
    """Complete agent configuration"""
    livekit: LiveKitConfig
    cartesia: CartesiaConfig
    openai: OpenAIConfig
    supermemory: SuprememoryConfig

    @staticmethod
    def from_env() -> "AgentConfig":
        """Load configuration from environment variables"""

        # LiveKit
        livekit_url = os.getenv("LIVEKIT_URL")
        if not livekit_url:
            raise ValueError("LIVEKIT_URL environment variable not set")

        livekit_api_key = os.getenv("LIVEKIT_API_KEY")
        if not livekit_api_key:
            raise ValueError("LIVEKIT_API_KEY environment variable not set")

        livekit_api_secret = os.getenv("LIVEKIT_API_SECRET")
        if not livekit_api_secret:
            raise ValueError("LIVEKIT_API_SECRET environment variable not set")

        livekit_config = LiveKitConfig(
            url=livekit_url,
            api_key=livekit_api_key,
            api_secret=livekit_api_secret,
        )

        # Cartesia
        cartesia_api_key = os.getenv("CARTESIA_API_KEY")
        if not cartesia_api_key:
            raise ValueError("CARTESIA_API_KEY environment variable not set")

        cartesia_stt_model = os.getenv("CARTESIA_STT_MODEL", "ink")
        cartesia_tts_model = os.getenv("CARTESIA_TTS_MODEL", "sonic-3")

        cartesia_config = CartesiaConfig(
            api_key=cartesia_api_key,
            stt_model=cartesia_stt_model,
            tts_model=cartesia_tts_model,
        )

        # OpenAI
        openai_api_key = os.getenv("OPENAI_API_KEY")
        if not openai_api_key:
            raise ValueError("OPENAI_API_KEY environment variable not set")

        openai_model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

        openai_config = OpenAIConfig(
            api_key=openai_api_key,
            model=openai_model,
        )

        # Supermemory (optional)
        supermemory_api_key = os.getenv("SUPERMEMORY_API_KEY")
        supermemory_base_url = os.getenv(
            "SUPERMEMORY_BASE_URL", "https://api.supermemory.ai"
        )

        supermemory_config = SuprememoryConfig(
            api_key=supermemory_api_key,
            base_url=supermemory_base_url,
        )

        return AgentConfig(
            livekit=livekit_config,
            cartesia=cartesia_config,
            openai=openai_config,
            supermemory=supermemory_config,
        )


# Personality templates for different moods
PERSONALITY_TEMPLATES = {
    "supportive": {
        "tone": "empathetic, kind, and encouraging",
        "opening": "I'm here to support you. How are you doing today?",
        "approach": "Ask clarifying questions and provide emotional support",
    },
    "accountability": {
        "tone": "direct, kind but firm, focused on action",
        "opening": "Let's talk about how your commitments went.",
        "approach": "Gently challenge, ask about progress on commitments",
    },
    "celebration": {
        "tone": "enthusiastic, warm, celebratory",
        "opening": "Great to hear from you! Tell me about your wins.",
        "approach": "Acknowledge progress, ask about next goals",
    },
}

# Device tools available to the agent
AVAILABLE_DEVICE_TOOLS = {
    "battery_level": {
        "description": "Get the device's current battery level",
        "params": {},
    },
    "flash_screen": {
        "description": "Flash the device screen to get user attention",
        "params": {"duration_ms": "Duration of flash in milliseconds"},
    },
    "vibrate": {
        "description": "Vibrate the device",
        "params": {"pattern": "Vibration pattern (short, long, double)"},
    },
    "get_location": {
        "description": "Get device location (requires user permission)",
        "params": {},
    },
    "capture_screenshot": {
        "description": "Capture device screenshot for context",
        "params": {},
    },
}

# VAD (Voice Activity Detection) configuration
VAD_CONFIG = {
    # Conservative: wait longer for user to finish speaking
    "conservative": {
        "min_speech_duration_ms": 200,
        "silence_duration_ms": 500,
        "threshold": 0.6,
        "speech_pad_ms": 50,
    },
    # Balanced: normal operation
    "balanced": {
        "min_speech_duration_ms": 100,
        "silence_duration_ms": 300,
        "threshold": 0.5,
        "speech_pad_ms": 30,
    },
    # Aggressive: respond faster
    "aggressive": {
        "min_speech_duration_ms": 50,
        "silence_duration_ms": 200,
        "threshold": 0.4,
        "speech_pad_ms": 20,
    },
}


def get_vad_config(mode: str = "balanced") -> dict:
    """Get VAD configuration for the specified mode"""
    return VAD_CONFIG.get(mode, VAD_CONFIG["balanced"])


def get_personality_prompt(mood: str) -> str:
    """Get personality prompt based on mood"""
    template = PERSONALITY_TEMPLATES.get(mood, PERSONALITY_TEMPLATES["supportive"])
    return f"""You are You+, a supportive AI accountability assistant.

Tone: {template['tone']}
Opening: {template['opening']}
Approach: {template['approach']}

Always:
1. Ask clarifying questions
2. Acknowledge emotions
3. Provide actionable suggestions
4. Follow up on previous commitments
5. Be genuine and authentic
6. Remember user context from Supermemory
"""
